# frozen_string_literal: true

require "alchemy/upgrader"

module Alchemy::Upgrader::Tasks
  class ElementViewsUpdater < Thor
    include Thor::Actions

    no_tasks do
      def rename_element_views
        puts "-- Removing '_view' suffix from element views"

        Dir.glob("#{elements_view_folder}/*_view.*").each do |file|
          FileUtils.mv(file, file.to_s.sub(/_view/, ""))
        end
      end

      def update_local_variable
        puts "-- Updating element views local variable to element name"

        Alchemy::Element.definitions.map { |e| e["name"] }.each do |name|
          view = Dir.glob("#{elements_view_folder}/_#{name}.*").last
          gsub_file(view, /\b#{name}_view\b/, name)
        end
      end
    end

    private

    def elements_view_folder
      Rails.root.join("app", "views", "alchemy", "elements")
    end
  end
end
