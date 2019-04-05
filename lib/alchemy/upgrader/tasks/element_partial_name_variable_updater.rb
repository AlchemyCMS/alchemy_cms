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
          gsub_file(view, /cache\(?element([,\s\w:\-,=>'"\?\/]*)\)?/, "cache(#{variable_name}\\1)")
          gsub_file(view, /render_essence_view_by_name\(?element([,\s\w:\-,=>'"\?\/]*)\)?/, "render_essence_view_by_name(#{variable_name}\\1)")
          gsub_file(view, /element_view_for\(?element([,\s\w:\-,=>'"\?\/]*)\)?/, "element_view_for(#{variable_name}\\1)")
          gsub_file(view, /element\.([\w\?]+)/, "#{variable_name}.\\1")
        end
      end
    end

    private

    def elements_view_folder
      Rails.root.join('app', 'views', 'alchemy', 'elements')
    end
  end
end
