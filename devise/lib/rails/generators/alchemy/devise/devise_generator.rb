require 'rails'

module Alchemy
  module Generators
    class DeviseGenerator < ::Rails::Generators::Base
      desc "This generator copies the Alchemy Devise configuration into your app."
      source_root File.expand_path('../../../../../config/initializers', File.dirname(__FILE__))

      def copy_devise_config
        copy_file "devise.rb", "#{Rails.root}/config/initializers/devise.rb"
        msg = <<-MSG
If your are upgrading from Alchemy < 2.5.0:

1. Add `gem 'devise-encryptable'` into your Gemfile
2. Run `bundle install`
3. Alter the encryptor and the stretches value in your devise config:

  # config/initializers/devise.rb
  ...
    config.stretches = Rails.env.test? ? 1 : 20
    config.encryptor = :authlogic_sha512

MSG
        puts msg
      end

    end
  end
end
