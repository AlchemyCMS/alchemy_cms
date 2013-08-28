module Alchemy
  class PasswordsController < Devise::PasswordsController
    helper 'Alchemy::Admin::Base', 'Alchemy::Pages'

    before_filter { enforce_ssl if ssl_required? && !request.ssl? }
    before_filter :set_translation

    layout 'alchemy/login'

    def new
      build_resource(email: params[:email])
    end

  private

    # Override for Devise method
    def new_session_path(resource_name)
      alchemy.login_path
    end

    def edit_password_url(resource, options={})
      alchemy.edit_password_url(options)
    end

    def after_sign_in_path_for(resource_or_scope)
      if can? :index, :dashboard
        alchemy.admin_dashboard_path
      else
        alchemy.root_path
      end
    end

  end
end
