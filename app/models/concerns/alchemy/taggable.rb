# frozen_string_literal: true

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
      def tagged_with(names = [], **args)
        if names.is_a? String
          names = names.split(/,\s*/)
        end

        unless args[:match]
          args[:match] = :all
        end

        if names.any?
          args[:names] = names
        end

        super(args)
      end

      # Returns all unique tags
      def tag_counts
        Gutentag::Tag.distinct.joins(:taggings)
          .where(gutentag_taggings: {taggable_type: name})
      end
    end
  end
end
