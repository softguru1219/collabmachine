require 'rails_helper'

describe PurchaseServiceplaceCart do
  describe ".create_purchase" do
    let!(:vendor_1) { create :user, first_name: "vendor", last_name: "one", email: "vendor1@example.com" }
    let!(:vendor_1_tax) { create :tax, name: "GST", rate: 5, user: vendor_1 }
    let!(:vendor_1_product) { create :product, title: "vendor_1_product", price: 100, taxes: [vendor_1_tax], user: vendor_1 }

    let!(:vendor_2) { create :user, first_name: "vendor", last_name: "two", email: "vendor2@example.com" }
    let!(:vendor_2_tax) { create :tax, name: "QST", rate: 10, user: vendor_2 }
    let!(:vendor_2_product) { create :product, title: "vendor_2_product", price: 200, taxes: [vendor_2_tax], user: vendor_2 }

    let!(:shopping_cart) { ShoppingCart.new([vendor_1_product, vendor_2_product]) }

    let!(:buyer) { create :user, first_name: "Buyer", last_name: "Name", email: "buyer@example.com" }

    it "creates the serviceplace purchase record" do
      purchase = PurchaseServiceplaceCart.create_purchase(shopping_cart, buyer)

      expect(purchase).to be_persisted
      expect(purchase.user).to eq(buyer)
      expect(purchase.state).to eq("created")
      expect(purchase.total_product_amount).to eq(300)
      expect(purchase.taxes).to include(
        TaxLine.new(name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(5))
      )
      expect(purchase.taxes).to include(
        TaxLine.new(name: "QST", rate_as_percent: BigDecimal(10), amount: BigDecimal(20))
      )
      expect(purchase.total_tax_amount).to eq(BigDecimal(25))
      expect(purchase.total_amount).to eq(325)

      vendor_1_order = purchase.orders.find { |o| o.vendor_id == vendor_1.id }
      expect(vendor_1_order.vendor_name).to eq("vendor one")
      expect(vendor_1_order.vendor_email).to eq("vendor1@example.com")
      expect(vendor_1_order.vendor).to eq(vendor_1)
      expect(vendor_1_order.total_product_amount).to eq(100)
      expect(vendor_1_order.taxes).to eq([TaxLine.new(
        name: "GST",
        rate_as_percent: BigDecimal(5),
        amount: BigDecimal(5)
      )])
      expect(vendor_1_order.total_tax_amount).to eq(BigDecimal(5))
      expect(vendor_1_order.total_amount).to eq(BigDecimal(105))
      expect(vendor_1_order.invoice_html).to be_a(String)
      expect(vendor_1_order.buyer).to eq(buyer)
      expect(vendor_1_order.buyer_name).to eq("Buyer Name")
      expect(vendor_1_order.buyer_email).to eq("buyer@example.com")

      vendor_1_line = vendor_1_order.order_lines[0]

      expect(vendor_1_line.product).to eq(vendor_1_product)
      expect(vendor_1_line.product_title).to eq("vendor_1_product")
      expect(vendor_1_line.product_price).to eq(100)
      expect(vendor_1_line.product_quantity).to eq(1)
      expect(vendor_1_line.product_amount).to eq(100)
      expect(vendor_1_line.taxes).to eq([TaxLine.new(
        id: vendor_1_tax.id,
        name: "GST",
        rate_as_percent: BigDecimal(5),
        amount: BigDecimal(5)
      )])
      expect(vendor_1_line.total_tax_amount).to eq(BigDecimal(5))
      expect(vendor_1_line.total_amount).to eq(BigDecimal(105))

      vendor_2_order = purchase.orders.find { |o| o.vendor_id == vendor_2.id }
      expect(vendor_2_order.vendor_name).to eq("vendor two")
      expect(vendor_2_order.vendor_email).to eq("vendor2@example.com")
      expect(vendor_2_order.vendor).to eq(vendor_2)
      expect(vendor_2_order.total_product_amount).to eq(200)
      expect(vendor_2_order.taxes).to eq([TaxLine.new(
        name: "QST",
        rate_as_percent: BigDecimal(10),
        amount: BigDecimal(20)
      )])
      expect(vendor_2_order.total_tax_amount).to eq(BigDecimal(20))
      expect(vendor_2_order.total_amount).to eq(BigDecimal(220))
      expect(vendor_2_order.invoice_html).to be_a(String)
      expect(vendor_2_order.buyer).to eq(buyer)
      expect(vendor_2_order.buyer_name).to eq("Buyer Name")
      expect(vendor_2_order.buyer_email).to eq("buyer@example.com")

      vendor_2_line = vendor_2_order.order_lines[0]

      expect(vendor_2_line.product).to eq(vendor_2_product)
      expect(vendor_2_line.product_title).to eq("vendor_2_product")
      expect(vendor_2_line.product_price).to eq(200)
      expect(vendor_2_line.product_quantity).to eq(1)
      expect(vendor_2_line.product_amount).to eq(200)
      expect(vendor_2_line.taxes).to eq([TaxLine.new(
        id: vendor_2_tax.id,
        name: "QST",
        rate_as_percent: BigDecimal(10),
        amount: BigDecimal(20)
      )])
      expect(vendor_2_line.total_tax_amount).to eq(BigDecimal("20"))
      expect(vendor_2_line.total_amount).to eq(BigDecimal("220"))
    end
  end

  describe ".process_purchase", vcr: true do
    let!(:buyer) { create :user, first_name: "Buyer", last_name: "Name" }
    let!(:vendor) { create :user }
    let!(:product) { create :product, user: vendor, price: 100 }
    let!(:shopping_cart) { ShoppingCart.new([product]) }
    let!(:purchase) { PurchaseServiceplaceCart.create_purchase(shopping_cart, buyer) }
    let!(:order) { purchase.orders.first }
    let!(:order_line) { order.order_lines.first }

    let!(:recommended_by) { create :user }
    let!(:recommendation) { create :product_recommendation, product: product, recommended_by_user: recommended_by, recommended_to_user: buyer }

    it "charges the purchase and pays out to the vendor" do
      assign_customer_with_source(buyer)
      vendor.setup_with_test_stripe_connect
      recommended_by.setup_with_test_stripe_connect

      expect(Stripe::PaymentIntent).to receive(:create).with(hash_including(
                                                               amount: 10000,
                                                               customer: buyer.stripe_customer_id,
                                                               payment_method: buyer.stripe_customer.default_source,
                                                               currency: 'CAD',
                                                               confirm: true
      )).and_call_original

      expect(Stripe::Transfer).to receive(:create).with(hash_including(
                                                          amount: 100,
                                                          currency: 'CAD'
      )).and_call_original

      expect(Stripe::Transfer).to receive(:create).with(hash_including(
                                                          amount: 9520,
                                                          currency: 'CAD'
      )).and_call_original

      expect(MessageMailer).to receive(:purchase_receipt).with(be_a(Purchase)).and_call_original

      processed_purchase = PurchaseServiceplaceCart.process_purchase(purchase)
      order.reload

      expect(processed_purchase.state).to eq("processed")

      # international card processing fee applies
      expect(order.stripe_fee_amount).to eq(BigDecimal("3.80"))
      expect(order.total_recommendation_payouts_amount).to eq(1)
      expect(order.total_app_fee_amount).to eq(BigDecimal("4.80"))
      expect(order.vendor_payout_amount).to eq(BigDecimal("95.20"))
      expect(order.buyer_stripe_charge_id).to be_a(String)
      expect(order.vendor_payout_stripe_transfer_id).to be_a(String)
      expect(order.exception).to eq(nil)
      expect(order.state).to eq("paid_out_to_vendor")

      expect(Message.order(created_at: :desc).first.subject).to eq("Buyer Name just made an order for $100.00")

      recommendation = order.order_lines.first.product_recommendations.first
      expect(recommendation.payout_amount).to eq(1)
      expect(recommendation.payout_rate).to eq(BigDecimal("0.01"))
      expect(recommendation.payout_stripe_transfer_id).to_not eq(nil)
      expect(recommendation.payout_exception).to eq(nil)
    end

    it "saves exceptions on the order record" do
      disabled_account_id = "acct_1HjCKSD4dGRv5T30"
      vendor.profiles.create!(provider: "stripe_connect", uid: disabled_account_id)

      processed_purchase = PurchaseServiceplaceCart.process_purchase(purchase)

      expect(processed_purchase.state).to eq("processed")

      order.reload
      expect(order.exception).to be_a(PurchaseServiceplaceCart::VendorPayoutsDisabledError)
      expect(order.state).to eq("created")
    end
  end

  describe ".assign_order_line_recommendations" do
    let!(:product) { create :product, price: 100 }
    let!(:recommended_by) { create :user }
    let!(:recommended_by_profile) { create :profile, user: recommended_by, provider: "stripe_connect" }
    let!(:recommended_to) { create :user, email: "recommended_to@example.com" }
    let!(:recommendation) { create :product_recommendation, product: product, recommended_by_user: recommended_by, recommended_to_user: recommended_to }
    let!(:other_recommendation) { create :product_recommendation }

    let!(:order) { create :order, buyer: recommended_to }
    let!(:order_line) { create :order_line, order: order, product: product, product_quantity: 1, product_price: 100, total_amount: 100 }

    it "sets the payouts for relevant recommendations" do
      PurchaseServiceplaceCart.assign_order_line_recommendations(order_line)

      recommendation.reload
      expect(recommendation.order_line).to eq(order_line)
      expect(recommendation.payout_rate).to eq(BigDecimal("0.01"))
      expect(recommendation.payout_amount).to eq(BigDecimal(1))
    end

    it "does not set payouts for recommendations whose users do not have stripe connected" do
      recommended_by_profile.destroy

      PurchaseServiceplaceCart.assign_order_line_recommendations(order_line)

      recommendation.reload
      expect(recommendation.order_line).to eq(order_line)
      expect(recommendation.payout_rate).to eq(nil)
      expect(recommendation.payout_amount).to eq(nil)
    end

    it "doesn't update other recommendations" do
      expect {
        PurchaseServiceplaceCart.assign_order_line_recommendations(order_line)
      }.to_not change { other_recommendation.reload.updated_at }
    end
  end
end
