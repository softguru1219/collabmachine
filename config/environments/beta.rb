require_relative "production"

Rails.application.configure do
  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  config.action_cable.url = 'wss://beta.collabmachine.com/cable'
  config.action_cable.allowed_request_origins = ['http://beta.collabmachine.com', /http:\/\/beta.collabmachine.*/, 'https://beta.collabmachine.com', /https:\/\/beta.collabmachine.*/]
end
