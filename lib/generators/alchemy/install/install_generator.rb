# frozen_string_literal: true
require "rails/generators"
require "alchemy/install/tasks"
require "alchemy/version"

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

      class_option :skip_db_create,
        type: :boolean,
        default: false,
        desc: "Skip creating the database during install."

      class_option :skip_mount,
        type: :boolean,
        default: false,
        desc: "Skip mounting into routes.rb during install."

      class_option :default_language_code,
        type: :string,
        default: "en",
        desc: "The default language code of your site."

      class_option :default_language_name,
        type: :string,
        default: "English",
        desc: "The default language name of your site."

      source_root File.expand_path("files", __dir__)

      def setup
        header
        say "Welcome to AlchemyCMS!"
        say "Let's begin with some questions.\n\n"
      end

      def mount
        return if options[:skip_mount]

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

      def add_npm_package
        if File.exist? app_root.join("package.json")
          run "yarn add @alchemy_cms/admin@~#{Alchemy.version}"
        elsif File.exist? app_root.join("config/importmap.rb")
          run "bin/importmap pin @alchemy_cms/admin@~#{Alchemy.version}"
        else
          log("Could not add alchemy admin package! Make sure you have a JS bundler installed", :warning)
        end
      end

      def copy_alchemy_entry_point
        if Dir.exist? app_root.join("app/javascript")
          if File.exist? app_root.join("config/importmap.rb")
            # We want the bundled package if using importmaps
            create_file app_root.join("app/javascript/alchemy_admin.js"), 'import "@alchemy_cms/dist/admin"'
          else
            # We want the normal package if using a bundler locally
            create_file app_root.join("app/javascript/alchemy_admin.js"), 'import "@alchemy_cms/admin"'
          end
        else
          log("Could not add alchemy admin entry point! Make sure you have a JS bundler installed", :warning)
        end
      end

      def set_primary_language
        header
        install_tasks.set_primary_language(
          code: options[:default_language_code],
          name: options[:default_language_name],
          auto_accept: options[:auto_accept]
        )
      end

      def setup_database
        rake("db:create", abort_on_failure: true) unless options[:skip_db_create]
        # We can't invoke this rake task, because Rails will use wrong engine names otherwise
        rake("alchemy:install:migrations", abort_on_failure: true)
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
