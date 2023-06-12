module TrackersHelper
  def time_since_last_log(user)
    return false if user.nil?

    if (log_entry = Tracker.current_blitz.where(user_id: user.id).order(created_at: :desc).first)
      time_ago = ((DateTime.now.to_i - log_entry.created_at.to_i) / 60) || false
    end

    time_ago || false
  end
end
