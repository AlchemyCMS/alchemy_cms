# frozen_string_literal: true

require "alchemy/upgrader"

module Alchemy::Upgrader::Tasks
  class AddPageVersions < Thor
    include Thor::Actions

    no_tasks do
      def create_page_versions_for_pages
        puts "Create page versions for pages.\n"
        Alchemy::Page.find_each do |page|
          next if page.versions.any?

          version = page.versions.create!
          page.elements.update_all(page_version_id: version.id)
          print "."
        end
        puts "\nDone."
      end
    end
  end
end
