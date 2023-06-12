module BlitzHelper
  def next_blitz_tag
    I18n.localize(Figaro.env.next_blitz_datetime.to_date, format: "blitz%Y%m%d")
  end

  def blitz_time_slots
    %w(9h15 9h50 10h25 11h00 11h35 LUNCH 13h00 13h35 14h10 14h45 15h20 15h55 16h30)
  end

  def no_meeting_no_row?(hours, time_selection, coach)
    # coach has no meeting
    skip_row = false
    min_index = hours.length - 13
    hours.each_with_index do |meeting_time, i|
      next unless meeting_time == time_selection && (i > min_index - 1)

      skip_row = true if ['x', 'X'].include?(coach[i]) || ['', nil, '?'].include?(coach[i])
    end

    skip_row
  end

  def has_zero_tracker(user, room, moment)
    moment_hour = moment.split('h')[0].to_i
    moment_minutes = moment.split('h')[1].to_i

    base = Figaro.env.next_blitz_datetime.to_datetime.change({ hour: moment_hour, min: moment_minutes, sec: 0 })
    lower_limit = base - 15.minutes
    higher_limit = base + 15.minutes

    t = Tracker.where(user_id: user.id, target: room).where("created_at >= ? AND created_at <= ?", lower_limit, higher_limit)
    t.count == 0
  end

  def has_trackers(user, room, moment)
    !has_zero_tracker(user, room, moment) == true
  end

  def participant_status(user, room, moment)
    if user.sign_in_count == 0
      # **A. VIOLET - Jamais connectés**
      # Ceux qui ne se sont jamais connectés sur Collab Machine (ou pas depuis la création de leur compte) - on peut supposer qu'ils n'ont même pas vu leur agenda de rencontres.
      { color: 'violet', caption: 'A. Jamais connectés' }
    elsif !user.last_seen_at&.today?
      # **B. ROUGE - Pas au Blitz**
      # Ceux qui ne se sont pas encore connectés durant la journée du Blitz
      { color: 'red', caption: 'B. Pas au Blitz' }
    elsif !user.last_seen_at&.today? and !user.online?
      # **C. ORANGE - Pas connectés**
      # Ceux qui se sont déjà connectés durant la journée mais ne le sont pas en ce moment
      { color: 'orange', caption: 'C. Pas connectés' }

    elsif user.last_seen_at&.today? and user.online? and has_zero_tracker(user, room, moment)
      # **D. JAUNE - Pas au rendez-vous**
      # Ceux qui sont connectés sur Collab Machine mais qui ne sont pas encore connectés dans leur salle de rencontre
      { color: 'yellow', caption: 'D. Pas au rendez-vous' }
    elsif user.last_seen_at&.today? and user.online? and !has_zero_tracker(user, room, moment)

      { color: 'green', caption: 'E. Arrivés' }
      # **E. VERT - Arrivés**
      # Les participants qui sont déjà arrivés et connectés dans leur salle de rencontre avec leur coach
    else
      { color: 'white', caption: '' }
    end
  end
end
