# frozen_string_literal: true
require_relative '../base'

module Alchemy
  module Generators
    class SiteLayoutsGenerator < Base
      desc "This generator generates your site layouts view partials."
      source_root File.expand_path('templates', __dir__)

      def create_partials
        @sites = Alchemy::Site.all
        return unless @sites

        @sites.each do |site|
          @site_name = site.name.parameterize.underscore
          conditional_template "layout.html.#{template_engine}", "#{site_layouts_dir}/_#{@site_name}.html.#{template_engine}"
        end
      end

      private

      def site_layouts_dir
        @_site_layouts_dir ||= "app/views/alchemy/site_layouts"
      end
    end
  end
end
