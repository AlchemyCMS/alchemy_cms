module Alchemy
  module Admin
    class TagsAutocomplete < ViewComponent::Base
      delegate :alchemy, to: :helpers

      def initialize(additional_class: nil)
        @additional_class = additional_class
      end

      def call
        content_tag("alchemy-tags-autocomplete", content, attributes)
      end

      private

      def attributes
        {
          placeholder: Alchemy.t(:search_tag),
          url: alchemy.autocomplete_admin_tags_path,
          class: @additional_class
        }
      end
    end
  end
end
