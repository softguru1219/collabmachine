module UsersHelper
  def masked_name_or_handle(user)
    if user.masked_name(current_user).present?
      user.masked_name(current_user)
    else
      user_handle(user)
    end
  end
  
  def name_or_handle(user)
    if user.full_name.present?
      user.full_name
    else
      user_handle(user)
    end
  end

  def user_handle(user)
    if user.username.present?
      "@#{user.username}"
    else
      user.handle_from_email
    end
  end

  def load_user(user_id)
    return false if user_id == 0 # zero means system

    case user_id
    when User
      user_id
    when String
      User.find_by(slug: user_id)
    else
      User.find(user_id)
    end
  end

  def link_to_user(user_id)
    user = load_user(user_id)
    return if user.nil?

    link_to masked_name_or_handle(user), user
  end

  def avatar_link_to_user(user_id, params = {})
    user = load_user(user_id)
    return if user.nil?

    options = {}
    options[:target] = ''
    options[:target] = '_blank' if params[:blank] == true
    options[:title] = masked_name_or_handle(user)
    classes = params[:class] ||= 'img-circle'
    link_to image_tag(user.thumb_avatar_url, class: classes, title: options[:title]), user, options
  end

  def user_caption_for_dropdown(user)
    return '' if user.nil?

    if user.profile_type == 'company'
      caption = "#{user.company} (#{user.masked_name(current_user)})"
    elsif !user.first_name.nil?
      caption = user.masked_name(current_user)
      caption += " (#{user.company})" if user.company?
    else
      caption =  user.username || user.email
    end

    caption = "~#{user.email}" if caption.blank?
    caption
  end

  def edit_permitted?(_user)
    user_signed_in? && (policy(@user).admin_or_mine? || current_user.employees.where(user_id: @user).present? || (current_user.has_company.present? && current_user.has_company.permission == "admin" && current_user.has_company.company.employees.where(user_id: @user).present?))
  end

  def translate_profile_type(profile_type)
    case profile_type
    when "company"
      profile_type = t("shared.company").capitalize
    when "personal"
      profile_type = t("shared.top_nav.employee").capitalize
    end
    profile_type
  end

  def company_employees
    ids = []
    if user_signed_in?
      if current_user.employees.present?
        current_user.employees.each do |employee|
          ids << employee.user_id
        end

        ids << current_user.id

      elsif current_user.has_company.present? && current_user.has_company.permission == "admin"
        @employees = current_user.has_company.company.employees
        @employees.each do |employee|
          ids << employee.user_id
        end

        ids << current_user.has_company.company_id
      end
    end

    User.where(active: true, id: ids)
  end

  def language_name language_code
    laguage_names = {
      en: 'English',
      fr: 'French',
      sp: 'Spanish',
      zh: 'Chinese',
      ar: 'Arabic',
      ru: 'Russian',
      hi: 'Hindi',
      pt: 'Portuguese'
    }
    
    laguage_names[language_code.to_sym]
  end
end