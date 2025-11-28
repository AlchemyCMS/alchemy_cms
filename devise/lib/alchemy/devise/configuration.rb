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
    end
  end
end
