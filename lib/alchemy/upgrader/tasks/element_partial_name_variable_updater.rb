# frozen_string_literal: true

require 'alchemy/upgrader'

module Alchemy::Upgrader::Tasks
  class ElementPartialNameVariableUpdater < Thor
    include Thor::Actions

    no_tasks do
      def update_element_views
        puts "-- Update element views local variable to partial name"
        Dir.glob("#{elements_view_folder}/*_view.*").each do |view|
          variable_name = File.basename(view).gsub(/^_([\w-]*)\..*$/, '\1')
          %w[
            cache
            render_essence_view_by_name
            element_view_for
          ].each do |method_name|
            gsub_file(view, /#{method_name}([\s(]+)element([^\w])/, "#{method_name}\\1#{variable_name}\\2")
          end
          gsub_file(view, /([\s(%={]+)element([^\w:"'])/, "\\1#{variable_name}\\2")
        end
      end
    end

    private

    def elements_view_folder
      Rails.root.join('app', 'views', 'alchemy', 'elements')
    end
  end
end
