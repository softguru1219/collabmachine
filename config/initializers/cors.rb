Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource "/products/*/embed", methods: [:get]
    resource "/products/*/embed_graphic", methods: [:get]
  end
end
