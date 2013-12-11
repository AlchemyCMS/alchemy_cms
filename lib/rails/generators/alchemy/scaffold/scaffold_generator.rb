require 'rails'

module Alchemy
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base

      ALCHEMY_VIEWS = %w(breadcrumb language_links messages navigation)

      desc "This generator generates the Alchemy scaffold."
      class_option :copy_views, :default => false, :type => :boolean, :desc => "Copy all Alchemy views into your app.", :aliases => '-v'
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_config_dir
        empty_directory "#{Rails.root}/config/alchemy"
      end

      def create_view_dirs
        empty_directory Rails.root.join("app/views/alchemy/elements")
        empty_directory Rails.root.join("app/views/alchemy/page_layouts")
      end

      def copy_view_dirs
        copy_alchemy_views if @options['copy_views']
      end

      def copy_config
        copy_file "#{config_path}/config.yml", "#{Rails.root}/config/alchemy/config.yml"
      end

      def copy_files
        copy_file "#{File.dirname(__FILE__)}/files/elements.yml", "#{Rails.root}/config/alchemy/elements.yml"
        template "page_layouts.yml.tt", "#{Rails.root}/config/alchemy/page_layouts.yml"
        copy_file "#{File.dirname(__FILE__)}/files/application.html.erb", "#{Rails.root}/app/views/layouts/application.html.erb"
        copy_file "#{File.dirname(__FILE__)}/files/_standard.html.erb", "#{Rails.root}/app/views/alchemy/page_layouts/_standard.html.erb"
      end

    private

      def config_path
        @config_path ||= File.expand_path('../../../../../config/alchemy', File.dirname(__FILE__))
      end

      def copy_alchemy_views
        ALCHEMY_VIEWS.each do |dir|
          src = File.expand_path("../../../../../app/views/alchemy/#{dir}", File.dirname(__FILE__))
          dest = Rails.root.join('app/views/alchemy', dir)
          directory src, dest
        end
      end

    end
  end
end
