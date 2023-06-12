class Order < ApplicationRecord
  # order for a particular vendor in the serviceplace

  include ActionView::Helpers::NumberHelper

  belongs_to :purchase
  belongs_to :vendor, class_name: "User", required: true
  belongs_to :buyer, class_name: "User", required: true

  has_many :order_lines, dependent: :destroy
  accepts_nested_attributes_for :order_lines

  has_many :product_recommendations, through: :order_lines

  attribute :taxes, TaxLine.to_array_type
  validates :taxes, store_model: true

  serialize :exception

  string_enum :state, %w(
    created
    vendor_account_verified
    charged_buyer
    recommendations_assigned
    recommendations_paid_out
    vendor_payout_calculated
    paid_out_to_vendor
  )

  validates_presence_of :stripe_fee_amount,
                        :total_app_fee_amount,
                        :vendor_payout_amount,
                        :buyer_stripe_charge_id,
                        :vendor_payout_stripe_transfer_id,
                        if: :state_is_paid_out_to_vendor?

  scope :charged, -> { where.not(buyer_stripe_charge_id: nil) }

  scope :by_failed, lambda { |option|
    case option
    when "all"
      all
    when "failed"
      where.not(exception: nil)
    when "succeeded"
      where(state: Order.states.paid_out_to_vendor, exception: nil)
    end
  }
  def self.failed_select_options
    ["all", "failed", "succeeded"]
  end

  filterrific(
    available_filters: [
      :by_failed,
      :sorted_by
    ],
    default_filter_params: { sorted_by: 'created_at_desc' }
  )

  # required for sorting by filterrific
  scope :sorted_by, lambda { |sort_option|
    direction = (/desc$/.match?(sort_option) ? "desc" : "asc").to_sym
    case sort_option.to_s
    when /^created_at/
      order(created_at: direction)
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def charged?
    buyer_stripe_charge_id.present?
  end

  def save_invoice_html
    invoice_html = ApplicationController.render(
      partial: 'orders/invoice',
      locals: { order: self }
    )

    update!(invoice_html: invoice_html)
  end

  def set_buyer(buyer)
    self.buyer = buyer
    self.buyer_name = buyer.full_name
    self.buyer_email = buyer.email
  end

  def paid_out?
    vendor_payout_stripe_transfer_id.present?
  end

  def notify_vendor
    Notifier.call(self, :created, audience: Message.audiences.private)
  end

  def notification_attributes
    {
      amount: number_to_currency(total_amount),
      buyer_name: buyer_name
    }
  end

  def notification_default_sender
    vendor_id
  end

  def notification_default_recipient
    vendor_id
  end

  def failed?
    exception.present?
  end
end
