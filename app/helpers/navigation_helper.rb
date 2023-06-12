module NavigationHelper
  def menu_link_for(anchor)
    if controller_is?('hello') and action_is?('index')
      landing_path(locale: I18n.locale, anchor: anchor, only_path: true)
    else
      landing_path(locale: I18n.locale, anchor: anchor)
    end
  end

  def ensure_navigation
    @navigation ||= [{ title: t('shared.home'), url: '/' }]
  end

  def navigation_add(full_paths)
    full_paths.each do |path|
      ensure_navigation << { title: path[:title], url: path[:url] }
    end
    ensure_navigation
  end
end