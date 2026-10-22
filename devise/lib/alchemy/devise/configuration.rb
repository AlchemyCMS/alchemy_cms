require "alchemy/configuration"

module Alchemy
  module Devise
    class Configuration < Alchemy::Configuration
      # Layout for Alchemy Devise controllers
      # Default is +alchemy/admin+
      option :layout, :string, default: "alchemy/admin"

      # Devise modules included in +Alchemy::User+ model
      #
      # === Default modules
      #
      #     [
      #       :database_authenticatable,
      #       :trackable,
      #       :validatable,
      #       :timeoutable,
      #       :recoverable,
      #       :rememberable
      #     ]
      #
      # If you want to add additional modules into the Alchemy user class append
      # them to this collection in an initializer in your app.
      #
      # === Example
      #
      #     # config/initializers/alchemy.rb
      #     Alchemy::Devise.config.devise_modules << :registerable
      #
      # If your app uses an old encryption that needs the +devise-encryptable+ gem
      # you also need to load the devise module.
      #
      #     Alchemy::Devise.config.devise_modules << :encryptable
      #
      option :devise_modules, :collection, collection_class: Set, item_type: :symbol, default: [
        :database_authenticatable,
        :trackable,
        :validatable,
        :timeoutable,
        :recoverable,
        :rememberable
      ]

      # Require the acting user to confirm their own password before Alchemy
      # roles are granted or changed
      #
      # Creating a user with roles and changing the roles of an existing user
      # both ask for the password of the user performing the change. Every
      # other user attribute can be edited with a valid session alone.
      #
      # === Example
      #
      #     # config/initializers/alchemy.rb
      #     Alchemy::Devise.config.require_password_for_role_change = false
      #
      option :require_password_for_role_change, :boolean, default: true

      # Alchemy roles that may only be granted or revoked with a password
      #
      # Only +admin+ can manage users, so granting any other role does not
      # cross a trust boundary and never asks for a password.
      #
      # === Example
      #
      #     # config/initializers/alchemy.rb
      #     Alchemy::Devise.config.privileged_user_roles << "editor"
      #
      option :privileged_user_roles, :collection, item_type: :string, default: %w[admin]
    end
  end
end
