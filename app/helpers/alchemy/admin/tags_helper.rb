module Alchemy
  module Admin
    module TagsHelper

      # Checks if the tagged_with param contains the given tag
      def filtered_by_tag?(tag)
        if params[:tagged_with].present?
          tags = params[:tagged_with].split(',')
          tags.include?(tag.name)
        else
          false
        end
      end

      # Adds the given tag to the tag filter.
      def add_to_tag_filter(tag)
        if params[:tagged_with].present?
          tags = params[:tagged_with].split(',')
          tags << tag.name
        else
          [tag.name]
        end
      end

      # Removes the given tag from the tag filter.
      def remove_from_tag_filter(tag)
        if params[:tagged_with].present?
          tags = params[:tagged_with].split(',')
          tags.delete_if { |t| t == tag.name }
        else
          []
        end
      end

      # Returns the tag filter from params.
      #
      # A tag can be added to the filter.
      # A tag can also be removed.
      #
      # Options are:
      #   * options (Hash):
      #   ** :add (ActsAsTaggableOn::Tag) - The tag that should be added to the tag-filter
      #   ** :remove (ActsAsTaggableOn::Tag) - The tag that should be removed from the tag-filter
      #
      def tag_filter(options={})
        case
          when options[:add]
            taglist = add_to_tag_filter(options[:add]) if options[:add]
          when options[:remove]
            taglist = remove_from_tag_filter(options[:remove]) if options[:remove]
          else
            return params[:tagged_with]
        end
        return nil if taglist.blank?
        taglist.uniq.join(',')
      end

    end
  end
end
