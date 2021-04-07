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

          repository = ElementsRepository.new(page.draft_version.elements.includes(*element_includes))
          ActiveRecord::Base.no_touching do
            repository.visible.not_nested.each do |element|
              Element.acts_as_list_no_update do
                Element::Duplicator.new(element, repository: repository).duplicate(
                  page_version: version,
                )
              end
            end
          end
        end
      end

      class DeleteElements
        attr_reader :elements

        def initialize(elements)
          @elements = elements
        end

        def call
          contents = Alchemy::Content.where(element_id: elements.map(&:id))
          contents.group_by(&:essence_type)
            .transform_values! { |value| value.map(&:essence_id) }
            .each do |class_name, ids|
              class_name.constantize.where(id: ids).delete_all
            end
          contents.delete_all
          elements.delete_all(:delete_all)
        end
      end

      private

      attr_reader :page

      # Load the pages public version or create one
      def public_version(public_on)
        page.public_version || page.versions.create!(public_on: public_on)
      end

      def element_includes
        [:nested_elements, { contents: { essence: :ingredient_association } }, :tags]
      end
    end
  end
end
