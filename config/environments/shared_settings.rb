# Les settings de ce fichiers sont chargés dans tous les environnements.
# Settings in config/environments/test|dev|production take precedence over those specified here.
#
Rails.application.configure do
  if Rails.env.development?
    ENV['domain'] = 'collab.localhost' # production domain
    ENV['host'] = nil
    ENV['google_analytics_id'] = 'UA-83017510-1'
  elsif Rails.env.staging?
    ENV['domain'] = 'staging.domain.com' # staging domain
    ENV['host'] = 'staging.domain.com'
    ENV['google_analytics_id'] = 'UA-######################################1008-1'
  elsif Rails.env.production?
    ENV['domain'] = 'collabmachine.com' # production domain
    ENV['host'] = 'collabmachine.com'
    ENV['google_analytics_id'] = 'UA-83017510-1'
  else
    ENV['domain'] = nil
    ENV['host'] = nil
    ENV['google_analytics_id'] = nil
  end
end
