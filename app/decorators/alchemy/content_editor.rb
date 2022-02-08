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
        deprecated? ? "deprecated" : nil,
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

    def has_warnings?
      definition.blank? || deprecated?
    end

    def warnings
      return unless has_warnings?

      if definition.blank?
        Logger.warn("Content #{name} is missing its definition", caller(1..1))
        Alchemy.t(:content_definition_missing)
      else
        deprecation_notice
      end
    end

    # Returns a deprecation notice for contents marked deprecated
    #
    # You can either use localizations or pass a String as notice
    # in the content definition.
    #
    # == Custom deprecation notices
    #
    # Use general content deprecation notice
    #
    #     - name: element_name
    #       contents:
    #         - name: old_content
    #           type: EssenceText
    #           deprecated: true
    #
    # Add a translation to your locale file for a per content notice.
    #
    #     en:
    #       alchemy:
    #         content_deprecation_notices:
    #           element_name:
    #             old_content: Foo baz widget is deprecated
    #
    # or use the global translation that apply to all deprecated contents.
    #
    #     en:
    #       alchemy:
    #         content_deprecation_notice: Foo baz widget is deprecated
    #
    # or pass string as deprecation notice.
    #
    #     - name: element_name
    #       contents:
    #         - name: old_content
    #           type: EssenceText
    #           deprecated: This content will be removed soon.
    #
    def deprecation_notice
      case definition["deprecated"]
      when String
        definition["deprecated"]
      when TrueClass
        Alchemy.t(name,
                  scope: [:content_deprecation_notices, element.name],
                  default: Alchemy.t(:content_deprecated))
      end
    end
  end
end
