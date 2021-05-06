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
      # Sends a publish notification to all registered publish targets
      #
      def publish!(public_on:)
        Page.transaction do
          version = public_version(public_on)
          DeleteElements.new(version.elements).call

          repository = page.draft_version.element_repository
          ActiveRecord::Base.no_touching do
            Element.acts_as_list_no_update do
              repository.visible.not_nested.each.with_index(1) do |element, position|
                Alchemy::DuplicateElement.new(element, repository: repository).call(
                  page_version_id: version.id,
                  position: position
                )
              end
            end
          end
        end

        Alchemy.publish_targets.each { |p| p.perform_later(page) }
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
