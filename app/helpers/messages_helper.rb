module MessagesHelper
  def icon_for_use_case(use_case)
    start = %w(start start_mission start_project)
    finish = %w(finish finish_mission finish_project)

    icon =
      case use_case
        # situation               # icon
      when 'open_for_candidate' then 'announcement'
      when 'assignment'         then 'child'
      when *start               then 'play'
      when *finish              then 'flag-checkered'
      else                      'microphone'
      end

    "fa fa-#{icon}"
  end
end
