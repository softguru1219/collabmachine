module ToggleHelper
  def true?(obj)
    obj.to_s == "true"
  end

  def blitz_coaching_active?
    true?(Figaro.env.blitz_coaching_active) || nil
  end

  def enabled_section_activity_feed?
    true?(Figaro.env.section_activity_feed) || nil
  end

  def enabled_section_projects?
    true?(Figaro.env.section_projects) || nil
  end

  def enabled_section_missions?
    true?(Figaro.env.section_missions) || nil
  end

  def enabled_section_user_messages?
    true?(Figaro.env.section_user_messages && current_user.admin?) || nil
  end

  def enabled_section_invoices?
    true?(Figaro.env.section_missions) || nil
  end
end
