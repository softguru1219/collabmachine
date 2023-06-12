class Invoice < ActiveRecord::Base
  APPLICATION_FEE_PERCENT = BigDecimal(20)
  STRIPE_FEE_PERCENT = BigDecimal("2.9")
  STRIPE_FEE_FIX = BigDecimal("0.3")

  belongs_to :user
  belongs_to :customer, class_name: 'User'

  has_many :invoice_lines
  has_many :item_taxes, through: :invoice_lines
  has_many :invoice_parents
  has_many :missions, through: :invoice_parents, source: :invoiceable, source_type: 'Mission'
  has_many :projects, through: :invoice_parents, source: :invoiceable, source_type: 'Project'

  has_one :payment, class_name: "Transaction"

  accepts_nested_attributes_for :invoice_lines,
                                reject_if: ->(a) { a[:description].blank? },
                                allow_destroy: true

  delegate :username, to: :customer, prefix: true
  delegate :username, to: :user, prefix: true

  filterrific(
    available_filters: [
      :by_customer,
      :by_client,
      :by_description,
      :by_state
    ]
  )

  scope :by_user, lambda { |user_id|
    where(user_id: user_id).or(self.where(customer_id: user_id))
  }

  scope :by_description, lambda { |query|
    return nil  if query.blank?

    terms = query.to_s.downcase.split(/\s+/)

    terms = terms.map do |e|
      "%#{e.tr('*', '%')}%".gsub(/%+/, '%')
    end

    num_or_conds = 2

    where(
      terms.map do
        "(LOWER(invoices.description) LIKE ? OR LOWER(invoice_lines.description) LIKE ?)"
      end.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    ).joins(:invoice_lines)
  }

  scope :by_client, lambda { |client_id|
    where(user_id: client_id)
  }

  scope :by_customer, lambda { |customer_id|
    where(customer_id: customer_id)
  }

  scope :by_state, lambda { |state|
    case state
    when "paid"
      includes(:payment).where.not(transactions: { id: nil }).where.not(transactions: { paid: false })
    when 'not paid'
      includes(:payment).where(transactions: { id: nil })
    end
  }

  validates :user, presence: true
  validates :customer, presence: true
  validates :invoice_lines, presence: true

  def amount
    invoice_lines.map(&:amount).sum
  end

  def amount_without_tax
    invoice_lines.map(&:amount_without_tax).sum
  end

  def taxes_with_total
    item_taxes.includes(:tax, :invoice_line).to_a.group_by(&:tax_id).map do |_k, arr|
      {
        name: arr.first.tax.name,
        rate: arr.first.tax.rate,
        sum: arr.sum(&:sum)
      }
    end
  end

  def paid?
    return false unless transaction

    transaction.paid?
  end

  def stripe_invoice
    Stripe::Invoice.retrieve(self.stripe_invoice_id, stripe_account: self.user.stripe_profile.uid)
  end

  def application_fee
    amount * APPLICATION_FEE_PERCENT / 100
  end

  def app_fee_rate
    1 + (APPLICATION_FEE_PERCENT / 100)
  end

  def stripe_fee
    (amount * (STRIPE_FEE_PERCENT / 100)) + STRIPE_FEE_FIX
  end

  def overall_amount
    (application_fee + amount).round(2)
  end

  def transaction
    Transaction.find_by(invoice_id: id)
  end

  def self.state_values
    [
      [I18n.t('invoice.index.state_filter.paid'), 'paid'],
      [I18n.t('invoice.index.state_filter.not_paid'), 'not paid']
    ]
  end
end
