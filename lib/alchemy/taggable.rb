module Alchemy
  # ActsAsTaggableOn to Gutentag interface compatibility module
  # Include this module to add tagging support to your model.
  module Taggable
    def self.included(base)
      Gutentag::ActiveRecord.call base
      base.extend ClassMethods
      base.send(:alias_method, :tag_list, :tag_names)
    end

    # Set a list of tags
    # Pass a String with comma separated tag names or
    # an Array of tag names
    def tag_list=(tags)
      case tags
      when String
        self.tag_names = tags.split(/,\s*/)
      when Array
        self.tag_names = tags
      end
    end

    module ClassMethods
      # Find all records matching all of the given tags.
      # Separate multiple tags by comma.
      def tagged_with(names)
        if names.is_a? String
          names = names.split(/,\s*/)
        end
        super(names: names, match: :all)
      end

      # Returns all unique tags
      def tag_counts
        Gutentag::Tag.distinct.joins(:taggings)
          .where(gutentag_taggings: {taggable_type: name})
      end
    end
  end
end
