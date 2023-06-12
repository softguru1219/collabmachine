module DeviseHelpers
  # see https://github.com/heartcombo/devise#controller-tests
  def set_devise_mapping
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
end

RSpec.configure do |config|
  config.include DeviseHelpers, type: :controller
  config.include DeviseHelpers, type: :view
end
