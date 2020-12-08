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

          Alchemy::Page.transaction do
            page.versions.create!.tap do |version|
              Alchemy::Element.where(page_id: page.id).update_all(page_version_id: version.id)
            end

            if page.public_on?
              page.versions.create!(
                public_on: page.public_on,
                public_until: page.public_until
              ).tap do |version|
                Alchemy::Element.where(page_id: page.id).not_nested.available.order(:position).find_each do |element|
                  Alchemy::Element.copy(element, page_version_id: version.id)
                end
              end
            end
          end

          print "."
        end
        puts "\nDone."
      end
    end
  end
end
