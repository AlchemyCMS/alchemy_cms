require "alchemy/devise/engine"

module Alchemy
  # Devise modules included in +Alchemy::User+ model
  #
  # === Default modules
  #
  #     [
  #.      :database_authenticatable,
  #       :trackable,
  #       :validatable,
  #       :timeoutable,
  #       :recoverable
  #.    ]
  #
  # If you want to add additional modules into the Alchemy user class append
  # them to this collection in an initializer in your app.
  #
  # === Example
  #
  #     # config/initializers/alchemy.rb
  #     Alchemy.devise_modules << :registerable
  #
  # If your app uses an old encryption that needs the +devise-encryptable+ gem
  # you also need to load the devise module.
  #
  #     Alchemy.devise_modules << :encryptable
  #
  def self.devise_modules
    @devise_modules ||= [
      :database_authenticatable,
      :trackable,
      :validatable,
      :timeoutable,
      :recoverable
    ]
  end

  module Devise
    def self.layout=(value)
      @layout = value
    end

    def self.layout
      @layout || "alchemy/admin"
    end
  end
end
