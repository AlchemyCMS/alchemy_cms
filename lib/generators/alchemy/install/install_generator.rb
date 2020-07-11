# frozen_string_literal: true
require "rails/generators"
require "alchemy/install/tasks"

module Alchemy
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs Alchemy into your App."

      class_option :auto_accept,
        type: :boolean,
        default: false,
        desc: "Automatically accept defaults."

      class_option :skip_demo_files,
        type: :boolean,
        default: false,
        desc: "Skip creation of demo element, page and application layout."

      class_option :skip_webpacker_installer,
        type: :boolean,
        default: false,
        desc: "Skip running the webpacker installer."

      source_root File.expand_path("files", __dir__)

      def setup
        header
        say "Welcome to AlchemyCMS!"
        say "Let's begin with some questions.\n\n"
        install_tasks.inject_routes(options[:auto_accept])
      end

      def copy_config
        copy_file "#{gem_config_path}/config.yml", app_config_path.join("alchemy", "config.yml")
      end

      def copy_yml_files
        %w(elements page_layouts menus).each do |file|
          template "#{__dir__}/templates/#{file}.yml.tt", app_config_path.join("alchemy", "#{file}.yml")
        end
      end

      def install_assets
        copy_file "all.js", app_vendor_assets_path.join("javascripts", "alchemy", "admin", "all.js")
        copy_file "all.css", app_vendor_assets_path.join("stylesheets", "alchemy", "admin", "all.css")
      end

      def copy_demo_views
        return if options[:skip_demo_files]

        copy_file "application.html.erb", app_views_path.join("layouts", "application.html.erb")
        copy_file "article.scss", app_assets_path.join("stylesheets", "alchemy", "elements", "article.scss")

        stylesheet_require = " *= require_tree ./alchemy/elements\n"
        if File.exist?(app_assets_path.join("stylesheets", "application.css"))
          insert_into_file app_assets_path.join("stylesheets", "application.css"), stylesheet_require,
            before: " */"
        else
          create_file app_assets_path.join("stylesheets", "application.css"), "/*\n#{stylesheet_require} */\n"
        end

        copy_file "_article.html.erb", app_views_path.join("alchemy", "elements", "_article.html.erb")
        copy_file "_standard.html.erb", app_views_path.join("alchemy", "page_layouts", "_standard.html.erb")
        copy_file "alchemy.en.yml", app_config_path.join("locales", "alchemy.en.yml")
      end

      def copy_dragonfly_config
        template(
          "#{__dir__}/templates/dragonfly.rb.tt",
          app_config_path.join("initializers", "dragonfly.rb"),
          skip: options[:auto_accept]
        )
      end

      def install_gutentag_migrations
        rake "gutentag:install:migrations"
      end

      def run_webpacker_installer
        unless options[:skip_webpacker_installer]
          # Webpacker does not create a package.json, but we need one
          unless File.exist? app_root.join("package.json")
            in_root { run "echo '{}' > package.json" }
          end
          rake("webpacker:install", abort_on_failure: true)
        end
      end

      def add_npm_package
        run "yarn add @alchemy_cms/admin"
      end

      def copy_alchemy_entry_point
        webpack_config = YAML.load_file(app_root.join("config", "webpacker.yml"))[Rails.env]
        copy_file "alchemy_admin.js",
          app_root.join(webpack_config["source_path"], webpack_config["source_entry_path"], "alchemy/admin.js")
      end

      def set_primary_language
        header
        install_tasks.set_primary_language(options[:auto_accept])
      end

      def setup_database
        rake("db:create", abort_on_failure: true)
        # We can't invoke this rake task, because Rails will use wrong engine names otherwise
        rake("railties:install:migrations", abort_on_failure: true)
        rake("db:migrate", abort_on_failure: true)
        install_tasks.inject_seeder
        rake("db:seed", abort_on_failure: true)
      end

      def finalize
        header
        say "Alchemy successfully installed!"
        say "Now start the server with:\n\n"
        say "  bin/rails server\n\n"
        say "and point your browser to\n\n"
        say "  http://localhost:3000/admin\n\n"
        say "and follow the onscreen instructions to finalize the installation.\n\n"
      end

      private

      def header
        return if options[:auto_accept]

        puts "─────────────────────"
        puts "* Alchemy Installer *"
        puts "─────────────────────"
      end

      def say(something)
        return if options[:auto_accept]

        puts "  #{something}"
      end

      def gem_config_path
        @_config_path ||= File.expand_path("../../../../config/alchemy", __dir__)
      end

      def app_config_path
        @_app_config_path ||= app_root.join("config")
      end

      def app_views_path
        @_app_views_path ||= app_root.join("app", "views")
      end

      def app_assets_path
        @_app_assets_path ||= app_root.join("app", "assets")
      end

      def app_vendor_assets_path
        @_app_vendor_assets_path ||= app_root.join("vendor", "assets")
      end

      def app_root
        @_app_root ||= Rails.root
      end

      def install_tasks
        @_install_tasks ||= Alchemy::Install::Tasks.new
      end
    end
  end
end
