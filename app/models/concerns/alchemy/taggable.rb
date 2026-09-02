# frozen_string_literal: true

module Alchemy
  # ActsAsTaggableOn to Gutentag interface compatibility module
  # Include this module to add tagging support to your model.
  module Taggable
    def self.included(base)
      Gutentag::ActiveRecord.call base
      base.extend ClassMethods

      # Opt-in denormalized cache, maintained only for taggables whose table
      # has a cached_tag_list column. serialize defers until the schema loads,
      # so declaring it unconditionally never touches the DB at boot and is
      # harmless for taggables without the column.
      base.attribute :cached_tag_list, default: -> { [] }
      base.serialize :cached_tag_list, coder: JSON
      base.before_save :remember_tag_name_change
      base.after_save :cache_tag_list
    end

    # The public list of tag names. Reads the denormalized cache column so the
    # common read paths (rendering, serializing) issue no query. Models without
    # the cache column fall back to gutentag's lazy-loading tag_names.
    #
    # The column is nullable, so rows written before the cache was introduced
    # read back nil, which we coerce to an empty array.
    def tag_list
      caches_tag_list? ? (cached_tag_list || []) : tag_names
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

    private

    # gutentag reconciles the tags in an after_save callback, and reading its
    # tag_names accessor before that runs would lazy-load from the still-empty
    # tags association of an unsaved record. So we remember whether the tags
    # changed here (query-free) and read the reconciled value after the save.
    def remember_tag_name_change
      @tag_names_changed = will_save_change_to_tag_names?
      true
    end

    # Keeps the denormalized cached_tag_list column in sync with the tags.
    # Only runs when the tags actually changed, so untagged saves stay
    # query-free.
    def cache_tag_list
      return unless @tag_names_changed
      return unless caches_tag_list?

      update_column(:cached_tag_list, Array(tag_names))
    end

    def caches_tag_list?
      self.class.column_names.include?("cached_tag_list")
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
