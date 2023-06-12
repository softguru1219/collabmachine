module ProductPathHelper
  def user_with_product_tab_path(product)
    user_path(product.user, anchor: "products_#{product.id}")
  end

  def load_product(product_id)
    return false if product_id == 0 # zero means system

    if product_id.to_i.to_s == product_id
      Product.with_attached_carousel_images.find(product_id)
    else
      Product.with_attached_carousel_images.find_by(slug: product_id)
    end
  end

  def load_product_to_review(product_id)
    return false if product_id == 0 # zero means system

    if product_id.to_i.to_s == product_id
      Product.find(product_id)
    else
      Product.find_by(slug: product_id)
    end
  end
end
