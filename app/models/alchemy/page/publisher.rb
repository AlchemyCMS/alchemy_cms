# frozen_string_literal: true

require_dependency "alchemy/page"

module Alchemy
  class Page < BaseRecord
    # Handles publishing of pages
    class Publisher
      def initialize(page)
        @page = page
      end

      # Copies all currently visible elements to the public version of page
      #
      # Creates a new published version if none exists yet.
      #
      def publish!(public_on:)
        Page.transaction do
          version = public_version(public_on)
          DeleteElements.new(version.elements).call

          repository = page.draft_version.element_repository
          repository.visible.not_nested.each do |element|
            Alchemy::DuplicateElement.new(element, repository: repository).call(
              page_version_id: version.id,
            )
          end
        end
      end

      private

      attr_reader :page

      # Load the pages public version or create one
      def public_version(public_on)
        page.public_version || page.versions.create!(public_on: public_on)
      end
    end
  end
end
