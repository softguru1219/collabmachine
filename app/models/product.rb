class Product < ApplicationRecord
  extend Mobility

  extend FriendlyId
  friendly_id :product_slug, use: :slugged

  attr_accessor :agreed_to_manage_taxes, :validate_tax_agreement

  translates :title, :description, :intended_audience, :value_proposition

  validates :agreed_to_manage_taxes, acceptance: true, if: :validate_tax_agreement

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0, less_than: 999999 }, unless: :is_free_item?
  validates :user, presence: true
  # validates :categories, presence: { message: I18n.t('g.one_category') }
  validates_uniqueness_of :product_slug, if: :product_slug?
  belongs_to :user, required: true

  before_validation do
    self.stripe_price_id = nil if self.stripe_price_id == ""
  end
  validates :stripe_price_id, presence: true, if: :buyable_subscription?
  validates :stripe_price_id, absence: true, unless: :buyable_subscription?

  has_many :specific_user_reviews, dependent: :destroy
  has_many :product_categorizations
  has_many :categories, through: :product_categorizations, source: :product_category
  has_many :product_taxes
  has_many :taxes, through: :product_taxes
  has_many :reviews, dependent: :destroy

  has_many_attached :carousel_images
  attribute :delete_carousel_image_ids, default: []
  after_update :cleanup_carousel_images

  def cleanup_carousel_images
    # sometimes #where is not present on #carousel_images here so we iterate through the array instead
    carousel_images.to_a.each { |i| i.purge if delete_carousel_image_ids.include?(i.id.to_s) }
  end

  string_enum :state, %w(
    for_review
    published
    archived
    rejected
  )

  string_enum :subscription_access_level, %w(
    premium
    platinum
    partner
  ), allow_nil: true

  after_create ->(product) { Notifier.call(product, :create, audience: Message.audiences.admin) }

  state_machine :state, initial: :for_review do
    after_transition(on: :publish) { |product, action| Notifier.call(product, action.event, audience: Message.audiences.private) }

    event :publish do
      transition for_review: :published
    end

    event :reject do
      transition for_review: :rejected
    end

    event :archive do
      transition [:for_review, :published] => :archived
    end
  end

  scope :by_title, lambda { |search_term|
    where_clause = I18n.available_locales.map do |locale|
      "products.title ->> '#{locale}' ILIKE :search_term"
    end.join(" OR ")

    where(where_clause, search_term: "%#{search_term}%")
  }

  scope :by_state, ->(search_term) { where(state: search_term) }
  scope :published, -> { where(state: Product.states.published) }

  scope :subscription, -> { where.not(subscription_access_level: nil) }
  scope :not_subscription, -> { where(subscription_access_level: nil) }
  scope :buyable, -> { where(buyable: true) }

  filterrific(
    available_filters: [
      :by_title,
      :by_state,
      :sorted_by
    ],
    default_filter_params: { sorted_by: 'title_asc' }
  )

  # required for sorting by filterrific
  scope :sorted_by, lambda { |sort_option|
    direction = (/desc$/.match?(sort_option) ? "desc" : "asc").to_sym
    case sort_option.to_s
    when /^title/
      order(title: direction)
    when /^created_at/
      order(created_at: direction)
    when /^updated_at/
      order(updated_at: direction)
    when /^state/
      order(state: direction)
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :published, -> { where(state: Product.states.published) }

  def notification_attributes
    {
      title: title,
      creator_first_name: user.first_name,
      creator_last_name: user.last_name
    }
  end

  def notification_default_sender
    user_id
  end

  def notification_default_recipient
    user_id
  end

  def card_image?
    carousel_images.first.present?
  end

  def card_image
    carousel_images.first&.variant(resize_to_limit: [231, 231])
  end

  def subscription?
    subscription_access_level.present?
  end

  def buyable_subscription?
    subscription? && buyable?
  end

  def is_free_item?
    !buyable?
  end
end
