class Alchemy::PasswordsController < Devise::PasswordsController
  helper 'Alchemy::Admin::Base', 'Alchemy::Pages'

  before_action { enforce_ssl if ssl_required? && !request.ssl? }
  before_action :set_translation

  layout 'alchemy/login'

  private

  # Override for Devise method
  def new_session_path(resource_name)
    alchemy.login_path
  end

  def edit_password_url(resource, options={})
    alchemy.edit_password_url(options)
  end

  def after_resetting_password_path_for(resource)
    if can? :index, :alchemy_admin_dashboard
      alchemy.admin_dashboard_path
    else
      alchemy.root_path
    end
  end

end
