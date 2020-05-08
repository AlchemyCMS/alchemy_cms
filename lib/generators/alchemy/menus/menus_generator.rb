# frozen_string_literal: true

require_relative "../base"

module Alchemy
  module Generators
    class MenusGenerator < Base
      desc "This generator generates Alchemy menu partials."
      source_root File.expand_path("templates", __dir__)

      def create_partials
        menus = Alchemy::Node.available_menu_names
        return unless menus

        menus.each do |menu|
          conditional_template "wrapper.html.#{template_engine}",
            "app/views/alchemy/menus/#{menu}/_wrapper.html.#{template_engine}"
          conditional_template "node.html.#{template_engine}",
            "app/views/alchemy/menus/#{menu}/_node.html.#{template_engine}"
        end
      end
    end
  end
end
