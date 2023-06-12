class Users::PasswordsController < Devise::PasswordsController
  layout 'empty', only: [:new, :edit]

  # GET /fr/users/password/new
  # under observation: been marked as UselessMethodDefinition by rubocop
  # Lint/UselessMethodDefinition: Useless method definition detected.
  # def new
  #   super
  # end
end
