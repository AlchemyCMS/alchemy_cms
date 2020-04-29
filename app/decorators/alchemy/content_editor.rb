# frozen_string_literal: true

module Alchemy
  class ContentEditor < SimpleDelegator
    alias_method :content, :__getobj__

    def to_partial_path
      "alchemy/essences/#{essence_partial_name}_editor"
    end

    def css_classes
      [
        "content_editor",
        essence_partial_name,
      ].compact
    end

    def data_attributes
      {
        content_id: id,
        content_name: name,
      }
    end

    # Returns a string to be passed to Rails form field tags to ensure we have same params layout everywhere.
    #
    # === Example:
    #
    #   <%= text_field_tag content_editor.form_field_name, content_editor.ingredient %>
    #
    # === Options:
    #
    # You can pass an Essence column_name. Default is 'ingredient'
    #
    # ==== Example:
    #
    #   <%= text_field_tag content_editor.form_field_name(:link), content_editor.ingredient %>
    #
    def form_field_name(essence_column = "ingredient")
      "contents[#{id}][#{essence_column}]"
    end

    def form_field_id(essence_column = "ingredient")
      "contents_#{id}_#{essence_column}"
    end

    # Fixes Rails partial renderer calling to_model on the object
    # which reveals the delegated content instead of this decorator.
    def respond_to?(method_name)
      return false if method_name == :to_model

      super
    end
  end
end
