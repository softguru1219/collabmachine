module PurchaseServiceplaceCart
  extend self

  def call(shopping_cart, buyer)
    purchase = create_purchase(shopping_cart, buyer)
    process_purchase(purchase)
    purchase
  end

  def create_purchase(shopping_cart, buyer)
    raise "Must have stripe customer" unless buyer.stripe_customer_id
    raise "Must have products" unless shopping_cart.products.any?

    purchase = shopping_cart.to_purchase
    purchase.user = buyer
    purchase.state = Purchase.states.created
    purchase.orders.each do |order|
      order.set_buyer(buyer)
      order.state = Order.states.created
    end
    purchase.save!

    purchase.orders.each(&:save_invoice_html)

    purchase
  end

  # we charge each order separately so we can authoritatively track the fees from the charge

  # we use separate charges and transfers rather than direct transfers because:
  # - it is recommended for transactions between multiple parties (https://stripe.com/docs/connect/charges#types)
  # - with direct transfers:
  #   - the card/customer must be tokenized first with a separate API call
  #   - it's not permitted to charge a customer from the base account (we would have to clone it first)
  #   - can't link transfers to other connect accounts which are on the base account
  #   - linked transfers are desirable for auditing and because they don't make funds available until original charge succeeds
  #   - payment does not appear in main account's payments listing
  #   - if we are unable to transfer a pointer amount after the initial direct payment then we would be left with excess app_fee
  # - we mitigate the risk of separate charges and transfer by verifying that the vendor account can accept payments before charging the buyer

  def process_purchase(purchase)
    purchase.orders.each do |order|
      process_order(order)
    end

    MessageMailer.purchase_receipt(purchase).deliver_now

    purchase.update!(state: Purchase.states.processed)

    purchase
  end

  def process_order(order)
    verify_vendor_account(order)
    charge = charge_order(order)
    assign_recommendations(order)
    payout_recommendations(order)
    calculate_vendor_payout(order, charge)
    payout_order(order)
    order.notify_vendor

    order
  rescue => e
    order.update_column(:exception, e)
  end

  def verify_vendor_account(order)
    account = Stripe::Account.retrieve(order.vendor.stripe_profile.uid)

    raise VendorPayoutsDisabledError.new(order.vendor.stripe_profile.uid) unless account.payouts_enabled

    order.update!(state: Order.states.vendor_account_verified)
  end

  class VendorPayoutsDisabledError < StandardError
    def initialize(account_id)
      @account_id = account_id
      super
    end

    def message
      "Payouts not enabled for stripe account #{@account_id}"
    end
  end

  def charge_order(order)
    intent = Stripe::PaymentIntent.create(
      amount: to_stripe_amount(order.total_amount),
      currency: 'CAD',
      confirm: true,
      customer: order.buyer.stripe_customer_id,
      payment_method: order.buyer.stripe_customer.default_source,
      description: "CollabMachine Order ##{order.id}",
      metadata: { cm_order_id: order.id }
    )

    charge = intent.charges.data[0]

    order.update!(buyer_stripe_charge_id: charge.id, state: Order.states.charged_buyer)

    charge
  end

  def assign_recommendations(order)
    order.order_lines.map { |ol| assign_order_line_recommendations(ol) }
    order.update!(state: Order.states.recommendations_assigned)
  end

  def assign_order_line_recommendations(order_line)
    product = order_line.product

    recommendations = ProductRecommendation.where(
      recommended_to_user: order_line.buyer,
      product: product,
      order_line: nil
    )

    recommendations.each do |recommendation|
      recommendation.order_line = order_line

      if ProductPolicy.new(recommendation.recommended_by_user, product).receive_recommendation_commission?
        recommendation.payout_rate = ProductRecommendation::PAYOUT_RATE
        recommendation.payout_amount = order_line.total_amount * recommendation.payout_rate
      end

      recommendation.save!
    end
  end

  def payout_recommendations(order)
    order.product_recommendations.select(&:payout_amount).each do |recommendation|
      payout_recommendation(recommendation, order)
    end
    order.update!(state: Order.states.recommendations_paid_out)
  end

  def payout_recommendation(recommendation, order)
    transfer = Stripe::Transfer.create(
      amount: to_stripe_amount(recommendation.payout_amount),
      currency: 'CAD',
      destination: recommendation.recommended_by_user.stripe_profile.uid,
      description: "Payout CollabMachine Product Recommendation: #{recommendation.product.title}",
      metadata: { cm_recommendation_id: recommendation.id },
      source_transaction: order.buyer_stripe_charge_id
    )
    recommendation.update!(payout_stripe_transfer_id: transfer.id)
  rescue => e
    recommendation.update_column(:payout_exception, e)
  end

  def calculate_vendor_payout(order, charge)
    stripe_fee = get_fee(charge)
    total_recommendation_payouts_amount = order.product_recommendations.select(&:paid_out?).sum(&:payout_amount)
    total_app_fee_amount = stripe_fee + total_recommendation_payouts_amount
    vendor_payout_amount = order.total_amount - total_app_fee_amount

    order.update!(
      stripe_fee_amount: stripe_fee,
      total_recommendation_payouts_amount: total_recommendation_payouts_amount,
      total_app_fee_amount: total_app_fee_amount,
      vendor_payout_amount: vendor_payout_amount,
      state: Order.states.vendor_payout_calculated
    )
  end

  def get_fee(charge)
    balance_transaction = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)

    stripe_fee = balance_transaction.fee_details.find { |detail| detail.type == "stripe_fee" }
    raise "Unexpected fee" unless stripe_fee.amount == balance_transaction.fee

    parse_stripe_amount(stripe_fee.amount)
  end

  def payout_order(order)
    transfer = Stripe::Transfer.create(
      amount: to_stripe_amount(order.vendor_payout_amount),
      currency: 'CAD',
      destination: order.vendor.stripe_profile.uid,
      description: "Payout for CollabMachine Order##{order.id}",
      metadata: { cm_order_id: order.id },
      source_transaction: order.buyer_stripe_charge_id
    )
    order.update!(vendor_payout_stripe_transfer_id: transfer.id, state: Order.states.paid_out_to_vendor)
  end

  # see https://stripe.com/docs/currencies#zero-decimal
  def to_stripe_amount(dollars)
    (dollars * BigDecimal(100)).to_i
  end

  def parse_stripe_amount(cents)
    BigDecimal(cents) / BigDecimal(100)
  end
end
