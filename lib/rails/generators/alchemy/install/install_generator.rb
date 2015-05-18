require 'rails'

module Alchemy
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      desc "Installs Alchemy into your App."

      class_option :skip_demo_files,
        type: :boolean,
        default: false,
        desc: "Skip creation of demo element, page and application layout."

      source_root File.expand_path('files', File.dirname(__FILE__))

      def create_view_dirs
        %w(elements page_layouts).each do |dir|
          empty_directory Rails.root.join("app/views/alchemy/#{dir}")
        end
      end

      def copy_config
        copy_file "#{config_path}/config.yml",
          Rails.root.join("config/alchemy/config.yml")
      end

      def copy_yml_files
        %w(elements page_layouts).each do |file|
          template "#{current_path}/templates/#{file}.yml.tt",
            Rails.root.join("config/alchemy/#{file}.yml")
        end
      end

      def copy_demo_views
        return if @options[:skip_demo_files]

        copy_file "application.html.erb",
          Rails.root.join("app/views/layouts/application.html.erb")
        copy_file "alchemy.elements.css.scss",
          Rails.root.join("app/assets/stylesheets/alchemy.elements.css.scss")

        [
          "_article_editor.html.erb",
          "_article_view.html.erb"
        ].each do |file|
          copy_file file, Rails.root.join("app/views/alchemy/elements/#{file}")
        end

        copy_file "_standard.html.erb",
          Rails.root.join("app/views/alchemy/page_layouts/_standard.html.erb")

        %w(de en es).each do |locale|
          copy_file "alchemy.#{locale}.yml",
            Rails.root.join("config/locales/alchemy.#{locale}.yml")
        end
      end

      private

      def config_path
        @_config_path ||= File.expand_path('../../../../../config/alchemy', current_path)
      end

      def current_path
        @_current_path ||= File.dirname(__FILE__)
      end
    end
  end
end
