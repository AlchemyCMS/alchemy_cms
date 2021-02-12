# frozen_string_literal: true

require "alchemy/upgrader"

module Alchemy::Upgrader::Tasks
  class AddPageVersions < Thor
    include Thor::Actions

    no_tasks do
      def create_public_page_versions
        Alchemy::Deprecation.silence do
          Alchemy::Page.where.not(legacy_public_on: nil).find_each do |page|
            next if page.versions.published.any?

            Alchemy::Page.transaction do
              page.versions.create!(
                public_on: page.legacy_public_on,
                public_until: page.legacy_public_until
              ).tap do |version|
                # We must not use .find_each here to not mess up the order of elements
                page.draft_version.elements.not_nested.available.each do |element|
                  Alchemy::Element.copy(element, page_version_id: version.id)
                end
              end
            end

            print "."
          end
        end
      end
    end
  end
end
