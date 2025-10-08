# frozen_string_literal: true

module Alchemy
  module Admin
    # Renders tags list items for given class name
    #
    class TagsList < ViewComponent::Base
      attr_reader :class_name

      delegate :search_filter_params, to: :helpers

      # @param class_name [String]
      #   The class_name representing a tagged class
      #
      def initialize(class_name)
        raise ArgumentError, "Please provide a String as class_name" if class_name.nil?
        @class_name = class_name
      end

      # @return [String]
      #   A HTML string containing <tt><li></tt> tags
      #
      def call
        sorted_tags.map do |tag|
          content_tag("li", name: tag.name, class: filtered_by_tag?(tag) ? "active" : nil) do
            link_to(
              "#{tag.name} (#{tag.taggings_count})",
              helpers.url_for(
                search_filter_params.except(:page, :tagged_with).merge(
                  tagged_with: tags_for_filter(current: tag).presence
                )
              ),
              remote: request.xhr?
            )
          end
        end.join.html_safe
      end

      private

      # Returns true if the given tag is in +params[:tagged_with]+
      #
      def filtered_by_tag?(tag)
        tags_from_params.include?(tag.name)
      end

      # Returns the tags from params suitable for the tags filter.
      #
      # @param current [Gutentag::Tag] - The current tag that will be added or removed if already present
      # @returns [String]
      def tags_for_filter(current:)
        if filtered_by_tag?(current)
          tags_from_params - Array(current.name)
        else
          tags_from_params.push(current.name)
        end.uniq.join(",")
      end

      # Returns tags from params
      # @returns [Array]
      def tags_from_params
        search_filter_params[:tagged_with].to_s.split(",")
      end

      def sorted_tags
        class_name.constantize.tag_counts.sort { |x, y| x.name.downcase <=> y.name.downcase }
      end
    end
  end
end
