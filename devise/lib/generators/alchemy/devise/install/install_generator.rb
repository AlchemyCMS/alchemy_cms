module Alchemy
  module Devise
    module Generators
      class InstallGenerator < Rails::Generators::Base
        desc "Installs Alchemy Devise based authentication into your app."
        source_root File.expand_path("templates", File.dirname(__FILE__))

        def copy_devise_config
          template "devise.rb.tt", "config/initializers/devise.rb"
        end

        def add_migrations
          run "bundle exec rake alchemy_devise:install:migrations"
        end

        def run_migrations
          run "bundle exec rake db:migrate"
        end

        def append_assets
          insert_into_file "vendor/assets/stylesheets/alchemy/admin/all.css",
            "\n *= require alchemy/admin/alchemy-devise",
            after: " *= require alchemy/admin"
        end
      end
    end
  end
end
