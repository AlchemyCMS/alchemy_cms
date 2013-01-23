module Alchemy
  class PasswordsController < Devise::PasswordsController

    before_filter { enforce_ssl if ssl_required? && !request.ssl? }
    before_filter :set_translation

    layout 'alchemy/admin'

    helper 'Alchemy::Admin::Base'

  private

    # Override for Devise method
    def new_session_path(resource_name)
      alchemy.login_path
    end

    def edit_password_url(resource, options={})
      alchemy.edit_password_url(options)
    end

  end
end