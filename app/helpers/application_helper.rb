module ApplicationHelper
  def stripe_url
    redirect_uri = user_stripe_connect_omniauth_callback_url.split('?').first
    redirect_uri.sub! "http://", "https://" unless Rails.env.development?
    "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=#{Figaro.env.stripe_connect_client_id}&scope=read_write&redirect_uri=#{redirect_uri}"
  end

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end

  def is_active_action(action_name)
    params[:action] == action_name ? "active" : nil
  end

  def controller_is?(name)
    request[:controller] == name
  end

  def action_is?(name)
    request[:action] == name
  end

  def show_tawk_to?
    true unless controller_is?('dashboard') and action_is?('meet')
  end

  def show_sidecar?
    true unless controller_is?('dashboard') and action_is?('meet')
  end

  def show_veeza?
    true unless controller_is?('dashboard') and action_is?('meet')
  end

  def default_path
    user_path(current_user) || home_path
  end

  def status_class_for(status)
    case status
    when 'draft'                then 'teal'
    when 'for_review'           then 'label-danger'
    when 'reviewed'             then 'blue'
    when 'open_for_candidates'  then 'green'
    when 'assigned'             then 'brown'
    when 'started'              then 'label-active'
    when 'finished'             then 'purple'
    when 'invoiced'             then 'yellow'
    when 'paid'                 then 'olive'
    when 'paid_confirmed'       then 'orange'
    else ''
    end
  end

  def alt_lang_path
    if request.fullpath.include? I18n.locale.to_s
      request.fullpath.sub(/#{I18n.locale}/, I18n.t('alt_lang.code'))
    elsif request.fullpath.include? "/#{I18n.t('alt_lang.code')}/"
      request.fullpath
    else
      "/#{I18n.t('alt_lang.code')}#{request.fullpath}"
    end
  end

  def check(value)
    if value
      content_tag(:i, '', class: 'fa fa-check')
    else
      content_tag(:i, '', class: 'fa fa-times')
    end.html_safe
  end

  def breadcrumb_path
    full_paths = []
    last_path_name = request.env['PATH_INFO'].split('/').last

    if last_path_name == 'wiphomepage'
      return
    end

    if last_path_name.present?
      split_paths = request.env['PATH_INFO'].split('/')
      original_split_paths = request.env['PATH_INFO'].split('/')

      split_paths.each_with_index do |path_name, idx|
        next_path_name = nil
        next_path_url = "#"
        path_url = nil

        next unless path_name.present?

        path_name = path_name.gsub('-', ' ').gsub('_', ' ')

        object_name = path_name.to_s.titleize.singularize.gsub(/[[:space:]]/, '')
        path_url = "/#{original_split_paths[1, idx].join('/')}"
        if split_paths[idx + 1].present?
          if path_name != "en" && path_name != "fr" && !is_number?(path_name)
            begin
              if path_name.length >= 30
                path_name = User.friendly.find(path_url.split('/').last).full_name
              end
            rescue Exception => ex
            end

            full_paths << { title: path_name, url: path_url } if path_url.present?
          end
          next_path_name = split_paths[idx + 1]
        elsif not is_number?(last_path_name)
          next_path_name = last_path_name.gsub('-', ' ').gsub('_', ' ')
          begin
            if next_path_name.length >= 30
              next_path_name = User.friendly.find(path_url.split('/').last).full_name
            end
          rescue Exception => ex
          end

          full_paths << { title: next_path_name, url: next_path_url }
          break
        end

        begin
          next_path_object = (Object.const_get object_name.to_s).where(id: next_path_name)
        rescue Exception => e
          next_path_object = nil
        end

        next unless next_path_object.present?

        next_path_name = if path_name == "users"
                           next_path_object.present? ? next_path_object.first.full_name : nil
                         elsif next_path_object.first["name"].is_a?(Hash)
                           next_path_object.first["name"][I18n.locale]
                         else
                           next_path_object.first["name"] || next_path_object.first["title"]
                         end

        next_path_url = "/#{original_split_paths[1, idx + 1].join('/')}" if idx + 1 < split_paths.length

        # full_paths << { title: path_name, url: path_url } if path_url.present?

        full_paths << { title: next_path_name, url: next_path_url } if next_path_name.present? & next_path_url.present?
      end
    end

    full_paths
  end

  def sitemap_page_title(url_element)
    title = nil
    url_element.children.each do |child_element|
      next unless child_element.namespace.prefix == 'news'

      child_element.children.each do |grand_child_element|
        title = grand_child_element.content if grand_child_element.name == 'title'
      end
    end
    title
  end

  def is_number?(string)
    true if Float(string) rescue false
  end

  def translate_breadcrum_title(title)
    case title
    when "Employees"
      title = t("shared.top_nav.#{title.downcase}").capitalize
    when "Sitemap"
      title = t("shared.#{title.downcase}").capitalize
    when "Specialties"
      title = t("specialty.#{title.downcase}").capitalize
    when "Results"
      title = t("shared.top_nav.#{title.downcase}").capitalize
    when "results"
      title = t("shared.top_nav.#{title}").downcase
    when "business domains"
      title = title.capitalize
    when "business sub domains"
      title = title.capitalize
    when "business categories"
      title = title.capitalize
    end

    title
  end
end