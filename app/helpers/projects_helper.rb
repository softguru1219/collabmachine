module ProjectsHelper
  def link_to_project(id)
    project = Project.find(id)
    link_to project.title, project
  end

  def room_url(jitsi_room)
    return "#" if jitsi_room.nil?
    return jitsi_room if jitsi_room.start_with?('http')

    # otherwise
    base_url = Rails.env.production? ? 'https://collabmachine.com' : 'http://localhost:3000'
    "#{base_url}#{jitsi_room}"
  end
end
