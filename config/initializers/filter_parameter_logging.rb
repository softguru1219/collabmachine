# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.

# known sensitive items
Rails.application.config.filter_parameters += [:password]

# pre-emptively filered sensitive items
Rails.application.config.filter_parameters += [:passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn]
