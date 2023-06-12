class ProductPolicy < UnauthenticatedPolicy
  def index?
    user&.gte_premium?
  end

  def embed_link?
    user && (user.admin? || record.user_id == user.id)
  end

  def create?
    publish_more_products?
  end

  def current_state_events
    all_state_events & record.state_events
  end

  def review_buyer?
    return true if user && review_buyer_checker?
  end

  def specific_user_review?(product)
    output = false
    unless product.specific_user_reviews&.nil?
      product.specific_user_reviews.each do |user_rev|
        output = true if user_rev.specific_user_email == user.email
      end
    end
    output
  end

  def review_buyer_checker?
    output = false
    unless user&.purchases.nil?
      user.purchases.each do |purchase|
        purchase.order_lines.each do |o_l|
          if o_l.product_id == record.id
            output = true
            break
          end
        end
      end
    end
    output
  end

  def all_state_events
    if user&.admin?
      events = [:reject, :archive]
      events << :publish if publish_more_products?
      events
    elsif user && (user.id == record.user_id)
      [:archive]
    else
      []
    end
  end

  # in general (not for a specific product)
  def publish_more_products?
    user &&
    (user.admin? ||
      (user.gte_platinum? && user.products.published.count < 10) ||
      (user.gte_premium? && user.products.published.count) < 5)
  end

  # for a specific product
  def publish?
    current_state_events.include?(:publish)
  end

  def archive?
    current_state_events.include?(:archive)
  end

  def reject?
    current_state_events.include?(:reject)
  end

  def update?
    user && (user.admin? || record.user_id == user.id)
  end

  def recommend?
    earn_recommendation_commission? && user.remaining_product_recommendations > 0
  end

  def earn_recommendation_commission?
    user&.gte_premium?
  end

  def receive_recommendation_commission?
    earn_recommendation_commission? && user.stripe_profile.present?
  end

  def admin?
    user&.admin?
  end

  def buy?
    record.published? && record.buyable?
  end

  def permitted_params(params)
    if user.admin?
      params.require(:product).permit(
        :price,
        :agreed_to_manage_taxes,
        :stripe_price_id, # admin only
        :subscription_access_level, # admin only
        :buyable, # admin only
        :product_slug,
        :accept_terms_product,
        :custom_product,
        *Utils::Locales.translated_param_names(
          :title,
          :description,
          :intended_audience,
          :value_proposition
        ),
        category_ids: [],
        tax_ids: [],
        carousel_images: [],
        delete_carousel_image_ids: []
      )
    elsif record == Product || record.user == user
      params.require(:product).permit(
        :price,
        :agreed_to_manage_taxes,
        :product_slug,
        :accept_terms_product,
        :custom_product,
        *Utils::Locales.translated_param_names(
          :title,
          :description,
          :intended_audience,
          :value_proposition
        ),
        category_ids: [],
        tax_ids: [],
        carousel_images: [],
        delete_carousel_image_ids: []
      )
    end
  end
end
