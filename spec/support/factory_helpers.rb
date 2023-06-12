module FactoryHelpers
  # reusable data setup that doesn't fit a normal factory definition

  extend self

  def insert_dashboard_seed_data
    create :user, username: 'wetsphalie_charles'
  end

  # rubocop:disable Style/OpenStructUse
  def build_nested_object(nested_hash)
    JSON.parse(nested_hash.to_json, object_class: OpenStruct)
  end
  # rubocop:enable Style/OpenStructUse

  def create_purchase_from_products_and_user(products, user, failed: false)
    cart = ShoppingCart.new(products)

    purchase = PurchaseServiceplaceCart.create_purchase(cart, user)
    simulate_purchase_processing(purchase) unless failed

    purchase
  end

  def simulate_purchase_processing(purchase)
    purchase.update!(state: Purchase.states.processed)
    purchase.orders.each do |order|
      stripe_fee_amount = (order.total_amount * BigDecimal("0.029")) + BigDecimal("0.30")

      order.update!(
        stripe_fee_amount: stripe_fee_amount,
        total_app_fee_amount: stripe_fee_amount,
        vendor_payout_amount: order.total_amount - stripe_fee_amount,
        buyer_stripe_charge_id: "buyer_stripe_charge_id",
        vendor_payout_stripe_transfer_id: "vendor_payout_stripe_transfer_id",
        state: Order.states.paid_out_to_vendor
      )
    end
  end

  def carousel_image_files
    Dir.glob(Rails.root.join("db", "seeds", "carousel_images", "*"))
  end
end
