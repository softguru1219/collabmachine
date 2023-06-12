class ProductsController < ApplicationController
  # can't eager load category products when also using `limit`
  around_action :skip_bullet, only: [:index]
  before_action :verify_stripe_connected, only: [:new, :create]
  skip_before_action :authenticate_user!, only: [:show, :embed, :embed_graphic, :send_message_to_merchant]
  after_action :verify_authorized, except: [:show, :embed, :embed_graphic, :send_message_to_merchant]
  before_action :allow_iframe_embed, only: [:embed, :embed_graphic]

  PRODUCT_STATE_ORDER = {
    Product.states.published => 4,
    Product.states.for_review => 3,
    Product.states.archived => 2,
    Product.states.rejected => 1
  }.freeze

  def index
    authorize Product

    @products = current_user.products.sort_by { |p| [(PRODUCT_STATE_ORDER[p.state] || 0), p.created_at] }.reverse
  end

  def show
    @product = helpers.load_product(params[:id])
    @skip_footer = true
    @body_classes = 'bg-light'
    @embed_code = "<iframe src='#{embed_product_url(@product)}' width='233' height='312' style='border: none;'></iframe>"
    @embed_graphic_code = "<iframe src='#{embed_graphic_product_url(@product)}' width='233' height='427' style='border: none;'></iframe>"
    @average_review = if @product.reviews.blank?
                        0
                      else
                        @product.reviews.average(:rating).round(2)
                      end

    sanitized_description = ActionController::Base.helpers.sanitize(
      @product.description.mb_chars.limit(400).to_s
    )

    prepare_meta_tags(
      title: @product.title,
      description: "#{sanitized_description}...",
      image: url_for(@product.card_image)
    )

    @merchant_data = {
      progress: {
        firstname: User.find(@product.user_id).first_name,
        email: User.find(@product.user_id).email
      }.to_json
    }

    if current_user && params[:embedded]
      render partial: "products/show", layout: false, locals: { product: @product }
    elsif current_user
      render :show, layout: "application"
    else
      render :show, layout: "front"
    end
  end

  def embed
    @product = helpers.load_product(params[:id])
    render :embed, layout: false
  end

  def embed_graphic
    @product = helpers.load_product(params[:id])
    render :embed_graphic, layout: false
  end

  def embed_link
    @product = helpers.load_product(params[:id])
    authorize @product
    @embed_code = "<iframe src='#{embed_product_url(@product)}' width='233' height='312' style='border: none;'></iframe>"
    @embed_graphic_code = "<iframe src='#{embed_graphic_product_url(@product)}' width='233' height='427' style='border: none;'></iframe>"
  end

  def new
    @body_classes = 'bg-light'

    authorize Product
    @product = Product.new
  end

  def create
    authorize Product
    @product = Product.new(product_params)
    @product.validate_tax_agreement = true
    @product.user = current_user
    @product.state = :for_review
    unless @product.title.nil?
      @same_title = Product.where(title: { "fr" => product_params["title_fr"] })
      @product.product_slug = if @same_title.empty?
                                @product.title.strip.gsub(" ", "-")
                              else
                                @product.title.strip.gsub(" ", "-") << "-#{@same_title.size}"
                              end
      @product.slug = @product.product_slug
    end

    if @product.save
      MessageMailer.notify_admin_product_review(@product)
      redirect_to helpers.user_with_product_tab_path(@product)
    else
      render :new
    end
  end

  def edit
    @body_classes = 'bg-light'
    @product = helpers.load_product(params[:id])

    authorize @product
  end

  def update
    @product = helpers.load_product(params[:id])

    authorize @product
    @product.assign_attributes(product_params)
    @product.slug = @product.product_slug
    if @product.save
      redirect_to helpers.user_with_product_tab_path(@product)
    else
      render :edit
    end
  end

  def publish
    @product = helpers.load_product(params[:id])
    authorize @product
    @product.publish

    redirect_to helpers.user_with_product_tab_path(@product), flash: {
      notice: t("products.publish.published")
    }
  end

  def archive
    @product = helpers.load_product(params[:id])
    authorize @product
    @product.archive

    redirect_to helpers.user_with_product_tab_path(@product), flash: {
      notice: t("products.archive.archived")
    }
  end

  def reject
    @product = helpers.load_product(params[:id])
    authorize @product
    @product.reject

    redirect_to helpers.user_with_product_tab_path(@product), flash: {
      notice: t("products.reject.rejected")
    }
  end

  def send_message_to_merchant
    # params[:sender] = 'support@collabmachine.com'
    if user_signed_in?
      params[:sender] = current_user.email
      MessageMailer.send_message_to_merchant(params).deliver_now
    else
      params[:sender] = 'support@collabmachine.com'
      MessageMailer.send_message_to_merchant_bigblue(params).deliver_now
    end

    # TODO: should catch if it worked or not.
    render json: { status: 'OK' }
  end

  private

  def allow_iframe_embed
    response.headers["X-FRAME-OPTIONS"] = "ALLOWALL"
  end

  def verify_stripe_connected
    unless current_user.stripe_profile
      session[:stripe_connect_redirect_path] = new_product_path
      redirect_to(helpers.stripe_url)
    end
  end

  def product_params
    policy(Product).permitted_params(params)
  end
end
