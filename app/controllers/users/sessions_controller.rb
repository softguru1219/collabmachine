class Users::SessionsController < Devise::SessionsController
  layout 'empty', only: [:new]

  # GET /resource/sign_in
  # under observation: been marked as UselessMethodDefinition by rubocop
  # Lint/UselessMethodDefinition: Useless method definition detected.
  # def new
  #   super
  # end
end
