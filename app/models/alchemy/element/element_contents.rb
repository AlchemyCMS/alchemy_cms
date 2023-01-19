# frozen_string_literal: true

module Alchemy
  class Element < BaseRecord
    # Methods concerning contents for elements
    #
    module ElementContents
      # Find first content from element by given name.
      # @deprecated
      def content_by_name(name)
        contents_by_name(name).first
      end

      deprecate content_by_name: :ingredient_by_role, deprecator: Alchemy::Deprecation

      # Find first content from element by given essence type.
      # @deprecated
      def content_by_type(essence_type)
        contents_by_type(essence_type).first
      end

      deprecate content_by_type: :ingredient_by_type, deprecator: Alchemy::Deprecation

      # All contents from element by given name.
      # @deprecated
      def contents_by_name(name)
        contents.select { |content| content.name == name.to_s }
      end

      deprecate contents_by_name: :ingredients_by_role, deprecator: Alchemy::Deprecation

      alias_method :all_contents_by_name, :contents_by_name

      # All contents from element by given essence type.
      # @deprecated
      def contents_by_type(essence_type)
        contents.select do |content|
          content.essence_type == Content.normalize_essence_type(essence_type)
        end
      end

      deprecate contents_by_type: :ingredients_by_type, deprecator: Alchemy::Deprecation

      alias_method :all_contents_by_type, :contents_by_type

      # Updates all related contents by calling +update_essence+ on each of them.
      #
      # @param contents_attributes [Hash]
      #   Hash of contents attributes.
      #   The keys has to be the #id of the content to update.
      #   The values a Hash of attribute names and values
      #
      # @return [Boolean]
      #   True if +errors+ are blank or +contents_attributes+ hash is nil
      #
      # == Example
      #
      #   @element.update_contents(
      #     "1" => {ingredient: "Title"},
      #     "2" => {link: "https://google.com"}
      #   )
      #
      # @deprecated
      def update_contents(contents_attributes)
        return true if contents_attributes.nil?

        contents.each do |content|
          content_hash = contents_attributes[content.id.to_s] || next
          content.update_essence(content_hash) || errors.add(:base, :essence_validation_failed)
        end
        errors.blank?
      end

      deprecate :update_contents, deprecator: Alchemy::Deprecation

      # Copy current content's contents to given target element
      # @deprecated
      def copy_contents_to(element)
        contents.map do |content|
          Content.copy(content, element_id: element.id)
        end
      end

      deprecate :copy_contents_to, deprecator: Alchemy::Deprecation

      # Returns the content that is marked as rss title.
      #
      # Mark a content as rss title in your +elements.yml+ file:
      #
      #   - name: news
      #     contents:
      #     - name: headline
      #       type: EssenceText
      #       rss_title: true
      #
      # @deprecated
      def content_for_rss_title
        content_for_rss_meta("title")
      end

      deprecate :content_for_rss_title, deprecator: Alchemy::Deprecation

      # Returns the content that is marked as rss description.
      #
      # Mark a content as rss description in your +elements.yml+ file:
      #
      #   - name: news
      #     contents:
      #     - name: body
      #       type: EssenceRichtext
      #       rss_description: true
      #
      # @deprecated
      def content_for_rss_description
        content_for_rss_meta("description")
      end

      deprecate :content_for_rss_description, deprecator: Alchemy::Deprecation

      # Returns the array with the hashes for all element contents in the elements.yml file
      # @deprecated
      def content_definitions
        return nil if definition.blank?

        definition["contents"]
      end

      deprecate content_definitions: :ingredient_definitions, deprecator: Alchemy::Deprecation

      # Returns the definition for given content_name
      # @deprecated
      def content_definition_for(content_name)
        if content_definitions.blank?
          log_warning "Element #{name} is missing the content definition for #{content_name}"
          nil
        else
          content_definitions.detect { |d| d["name"] == content_name.to_s }
        end
      end

      deprecate content_definition_for: :ingredient_definition_for, deprecator: Alchemy::Deprecation

      # Returns an array of all EssenceRichtext contents ids from elements
      #
      # This is used to re-initialize the TinyMCE editor in the element editor.
      #
      # @deprecated
      def richtext_contents_ids
        # This is not very efficient SQL wise I know, but we need to iterate
        # recursivly through all descendent elements and I don't know how to do this
        # in pure SQL. Anyone with a better idea is welcome to submit a patch.
        ids = contents.select(&:has_tinymce?).collect(&:id)
        expanded_nested_elements = nested_elements.expanded
        if expanded_nested_elements.present?
          ids += expanded_nested_elements.collect(&:richtext_contents_ids)
        end
        ids.flatten
      end

      deprecate richtext_contents_ids: :richtext_ingredients_ids, deprecator: Alchemy::Deprecation

      # True, if any of the element's contents has essence validations defined.
      # @deprecated
      def has_validations?
        !contents.detect(&:has_validations?).blank?
      end

      deprecate :has_validations?, deprecator: Alchemy::Deprecation

      # All element contents where the essence validation has failed.
      # @deprecated
      def contents_with_errors
        contents.select(&:essence_validation_failed?)
      end

      deprecate contents_with_errors: :ingredients_with_errors, deprecator: Alchemy::Deprecation

      private

      def content_for_rss_meta(type)
        definition = content_definitions.detect { |c| c["rss_#{type}"] }
        return if definition.blank?

        contents.detect { |content| content.name == definition["name"] }
      end

      # creates the contents for this element as described in the elements.yml
      #
      # If ingredients are defined as well no contents get created,
      # ingredients get created instead.
      def create_contents
        return if definition.fetch(:ingredients, []).any?

        definition.fetch("contents", []).each do |attributes|
          Content.create(attributes.merge(element: self))
        end
      end
    end
  end
end
