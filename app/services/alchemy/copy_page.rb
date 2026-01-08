# frozen_string_literal: true

module Alchemy
  # Creates a copy of given source page.
  #
  # Also copies all elements included in source page.
  #
  # === Note:
  #
  # It prevents the element auto generator from running.
  class CopyPage
    DEFAULT_ATTRIBUTES_FOR_COPY = {
      autogenerate_elements: false,
      public_on: nil,
      public_until: nil,
      locked_at: nil,
      locked_by: nil
    }

    SKIPPED_ATTRIBUTES_ON_COPY = %w[
      id
      updated_at
      created_at
      creator_id
      updater_id
      lft
      rgt
      depth
      urlname
      cached_tag_list
      title
      meta_description
      meta_keywords
    ]

    # Metadata to copy via nested attributes (title is derived from page.name)
    METADATA_ATTRIBUTES_TO_COPY = (Alchemy::PageVersion::METADATA_ATTRIBUTES - %w[title]).freeze

    attr_reader :page

    # @param page [Alchemy::Page]
    #   The source page the copy is taken from
    def initialize(page:)
      @page = page
    end

    # @param changed_attributes [Hash]
    #   A optional hash with attributes that take precedence over the source attributes
    #
    # @return [Alchemy::Page]
    #
    def call(changed_attributes:)
      Alchemy::Page.transaction do
        new_page = Alchemy::Page.new(attributes_from_source_for_copy(changed_attributes))
        new_page.tag_list = page.tag_list
        if new_page.save!
          Alchemy::Page.copy_elements(page, new_page)
        end
        new_page
      end
    end

    private

    # Aggregates the attributes from given source for copy of page.
    #
    # @param [Alchemy::Page]
    #   The source page
    # @param [Hash]
    #   A optional hash with attributes that take precedence over the source attributes
    #
    def attributes_from_source_for_copy(differences = {})
      source_attributes = page.attributes.stringify_keys
      differences.stringify_keys!
      desired_attributes = source_attributes
        .merge(DEFAULT_ATTRIBUTES_FOR_COPY)
        .merge(differences)
      desired_attributes["name"] = best_name_for_copy(source_attributes, desired_attributes)
      desired_attributes["draft_version_attributes"] = draft_version_attributes_for_copy
      desired_attributes.except(*SKIPPED_ATTRIBUTES_ON_COPY)
    end

    # Returns a new name for copy of page.
    #
    # If the differences hash includes a new name this is taken.
    # Otherwise +source.name+
    #
    # @param [Hash]
    #   The differences hash that contains a new name
    # @param [Hash]
    #   The name of the source
    #
    def best_name_for_copy(source_attributes, desired_attributes)
      desired_name = desired_attributes["name"].presence || source_attributes["name"]

      new_parent_id = desired_attributes["parent"]&.id || desired_attributes["parent_id"]

      if Alchemy::Page.where(parent_id: new_parent_id, name: desired_name).exists?
        "#{desired_name} (#{Alchemy.t("Copy")})"
      else
        desired_name
      end
    end

    # Builds nested attributes for draft_version metadata (except title).
    # Title is handled by PageVersion#set_title_from_page callback based on page.name.
    def draft_version_attributes_for_copy
      return {} unless page.draft_version

      METADATA_ATTRIBUTES_TO_COPY.each_with_object({}) do |attr, hash|
        hash[attr] = page.draft_version.send(attr)
      end
    end
  end
end
