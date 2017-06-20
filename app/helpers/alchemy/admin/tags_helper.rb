module Alchemy
  module Admin
    module TagsHelper
      # Renders tags list items for given class name
      #
      # @param class_name [String]
      #   The class_name representing a tagged class
      #
      # @return [String]
      #   A HTML string containing <tt><li></tt> tags
      #
      def render_tag_list(class_name)
        raise ArgumentError, 'Please provide a String as class_name' if class_name.nil?
        li_s = []
        class_name.constantize.tag_counts.sort { |x, y| x.name.downcase <=> y.name.downcase }.each do |tag|
          tags = filtered_by_tag?(tag) ? tag_filter(remove: tag) : tag_filter(add: tag)
          li_s << content_tag('li', name: tag.name, class: tag_list_tag_active?(tag) ? 'active' : nil) do
            link_to(
              "#{tag.name} (#{tag.count})",
              url_for(
                tag_list_params.reject { |k, _v| k == "page" }.merge(
                  action: 'index',
                  tagged_with: tags
                )
              ),
              remote: request.xhr?,
              class: 'please_wait'
            )
          end
        end
        li_s.join.html_safe
      end

      # Returns true if the given tag is in +params[:tag_list]+
      #
      # @param tag [ActsAsTaggableOn::Tag]
      #   the tag
      # @param params [Hash]
      #   url params
      # @return [Boolean]
      #
      def tag_list_tag_active?(tag)
        tag_list_params[:tagged_with].to_s.split(',').include?(tag.name)
      end

      # Checks if the tagged_with param contains the given tag
      def filtered_by_tag?(tag)
        if tag_list_params[:tagged_with].present?
          tags = tag_list_params[:tagged_with].split(',')
          tags.include?(tag.name)
        else
          false
        end
      end

      # Adds the given tag to the tag filter.
      def add_to_tag_filter(tag)
        if tag_list_params[:tagged_with].present?
          tags = tag_list_params[:tagged_with].split(',')
          tags << tag.name
        else
          [tag.name]
        end
      end

      # Removes the given tag from the tag filter.
      def remove_from_tag_filter(tag)
        if tag_list_params[:tagged_with].present?
          tags = tag_list_params[:tagged_with].split(',')
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
      def tag_filter(options = {})
        case
        when options[:add]
          taglist = add_to_tag_filter(options[:add]) if options[:add]
        when options[:remove]
          taglist = remove_from_tag_filter(options[:remove]) if options[:remove]
        else
          return tag_list_params[:tagged_with]
        end
        return nil if taglist.blank?
        taglist.uniq.join(',')
      end

      def tag_list_params
        params.permit(
          :controller,
          :content_id,
          :element_id,
          :options,
          :swap,
          :use_route,
          :tagged_with,
          :filter,
          q: params.fetch(:q, {}).keys
        )
      end
    end
  end
end
