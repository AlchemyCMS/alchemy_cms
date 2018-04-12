require 'rails'

module Alchemy
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs Alchemy into your App."

      class_option :skip_demo_files,
        type: :boolean,
        default: false,
        desc: "Skip creation of demo element, page and application layout."

      source_root File.expand_path('files', __dir__)

      def copy_config
        copy_file "#{config_path}/config.yml", "config/alchemy/config.yml"
      end

      def copy_yml_files
        %w(elements page_layouts).each do |file|
          template "#{__dir__}/templates/#{file}.yml.tt", "config/alchemy/#{file}.yml"
        end
      end

      def install_assets
        copy_file "all.js", "vendor/assets/javascripts/alchemy/admin/all.js"
        copy_file "all.css", "vendor/assets/stylesheets/alchemy/admin/all.css"
      end

      def copy_demo_views
        return if @options[:skip_demo_files]

        copy_file "application.html.erb", "app/views/layouts/application.html.erb"
        copy_file "article.scss", "app/assets/stylesheets/alchemy/elements/article.scss"

        stylesheet_require = " *= require_tree ./alchemy/elements\n"
        if File.exist?("app/assets/stylesheets/application.css")
          insert_into_file "app/assets/stylesheets/application.css", stylesheet_require,
            before: " */"
        else
          create_file "app/assets/stylesheets/application.css", "/*\n#{stylesheet_require} */\n"
        end

        [
          "_article_editor.html.erb",
          "_article_view.html.erb"
        ].each do |file|
          copy_file file, "app/views/alchemy/elements/#{file}"
        end

        copy_file "_standard.html.erb", "app/views/alchemy/page_layouts/_standard.html.erb"

        %w(de en es).each do |locale|
          copy_file "alchemy.#{locale}.yml", "config/locales/alchemy.#{locale}.yml"
        end
      end

      def copy_dragonfly_config
        template "#{__dir__}/templates/dragonfly.rb.tt", "config/initializers/dragonfly.rb"
      end

      private

      def config_path
        @_config_path ||= File.expand_path('../../../../../config/alchemy', __dir__)
      end
    end
  end
end
