require "application_responder"

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  self.responder = ApplicationResponder
  respond_to :html, :json

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # to revisit / to fix
  # impersonates :user

  before_action :store_location!,
                unless: -> { devise_controller? || request.xhr? },
                if: -> { request.get? && is_navigational_format? }

  before_action :authenticate_user!,
                unless: :devise_controller?

  before_action :set_mailer_host
  before_action :set_locale
  before_action :prepare_meta_tags, if: -> { request.get? }
  # before_action :teaser_homepage_title, if: -> { request.get? }
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :render_global_js_data

  after_action :actif?
  after_action :user_activity, :set_cookies

  # for sortable table columns feature
  helper_method :sort_column, :sort_direction
  helper_method :logged_in?, :access_level_is_admin?
  helper_method :session_path
  helper_method :new_session_path

  def set_cookies
    cookies.encrypted[:user_id] = current_user.id if current_user
  end

  def session_path(_scope)
    user_session_path
  end

  def new_session_path(_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    after_sign_in_url = stored_location_for(resource_or_scope)
    sign_in_root_url = signed_in_root_path(resource_or_scope)
    if after_sign_in_url == "/"
      dashboard_path || sign_in_root_url
    else
      after_sign_in_url || sign_in_root_url
    end
  end

  def access_level_is_admin?
    current_user&.admin?
  end

  def logged_in?
    current_user
  end

  def actif?
    if current_user.present? && !current_user.active
      sign_out current_user
      dashboard_path
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }.merge(options)
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def check_terms
    redirect_to accept_terms_path(then: request.url) unless current_user[:terms_accepted_at]
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:terms_accepted_at])
    devise_parameter_sanitizer.permit(:user_update, keys: [:terms_accepted_at])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_accepted_at, :first_name, :last_name, :active, :description, :github_url, :linkedin_url, :web_site_url, :company])
  end

  private

  def store_location!
    # from Devise::Controllers::StoreLocation
    # :user is the scope
    store_location_for(:user, request.fullpath)
  end

  # for column sorting
  # default
  def sort_column
    params[:sort] || default_sort_column
  end

  # default
  def sort_direction
    dir = params[:direction] || default_sort_order
    dir&.downcase
    %w[asc desc].include?(dir) ? dir : "asc"
  end

  def user_activity
    current_user.try(:touch, :last_seen_at)
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default

    if current_user
      redirect_to(request.referrer || user_path(current_user || root_path))
    else
      # redirect_to(request.referrer || default_path)
      flash[:alert] = "You need to login first."
      redirect_to new_user_session_path
    end
  end

  def prepare_meta_tags(options = {})
    return if controller_name == "sessions"
    
    if params[:controller] == "hello" && params[:action] == 'teaser_homepage'
      site_name = "CollabMachine.com | Personnel informatique e-commerce marketing"
      description = "Nous avons tous les spécialistes pour réaliser vos projets informatiques, e-commerce ou marketing. Personnel temporaire dans des centaines de spécialités."
      keywords = ["Collab Machine", "projet informatique", "projet e-commerce", "projet en marketing digital", "spécialistes", "Personnel temporaire", "RH"]
    else
      site_name = "Collab Machine"
      description = Rails::Html::FullSanitizer.new.sanitize(options[:description] || [t("company.description"), t("company.description_more")].join(" "))
      keywords = %w[web software development mobile travail autonome freelance]
    end
    
    title = options[:title]
    image = options[:image] || ""
    current_url = request.url

    # Let's prepare a nice set of defaults
    defaults = {
      site: site_name,
      title: title,
      image: image,
      description: description,
      keywords: keywords,
      twitter: {
        site_name: site_name,
        site: "@collab_machine",
        card: "summary",
        description: description,
        image: image
      },
      og: {
        url: current_url,
        site_name: site_name,
        title: title,
        image: image,
        description: description,
        type: "website"
      }
    }

    options.reverse_merge!(defaults)
    set_meta_tags options
  end

  def skip_bullet
    (yield && return) unless defined?(Bullet)

    previous_value = Bullet.enable?
    Bullet.enable = false
    yield
  ensure
    Bullet.enable = previous_value if defined?(Bullet)
  end

  def render_js_data(key, data)
    @js_data ||= {}

    raise "Duplicate key #{key}" if @js_data.key?(key)

    @js_data[key] = data
  end

  def render_global_js_data
    render_js_data("cart", ShoppingCart.verify_and_present(session))
    render_js_data("csrfToken", form_authenticity_token)
    render_js_data("locale", I18n.locale)
  end

  def verify_full_name
    redirect_to edit_user_path(current_user), flash: { notice: t("application.add_full_name") } unless current_user.has_full_name?
  end
end
