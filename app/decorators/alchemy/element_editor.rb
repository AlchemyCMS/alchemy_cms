# frozen_string_literal: true

module Alchemy
  class ElementEditor < SimpleDelegator
    alias_method :element, :__getobj__

    def to_partial_path
      "alchemy/admin/elements/element"
    end

    # CSS classes for the element editor partial.
    def css_classes
      [
        "element-editor",
        content_definitions.present? ? "with-contents" : "without-contents",
        nestable_elements.any? ? "nestable" : "not-nestable",
        taggable? ? "taggable" : "not-taggable",
        folded ? "folded" : "expanded",
        compact? ? "compact" : nil,
        deprecated? ? "deprecated" : nil,
        fixed? ? "is-fixed" : "not-fixed",
        public? ? "visible" : "hidden",
      ].join(" ")
    end

    # Tells us, if we should show the element footer and form inputs.
    def editable?
      return false if folded?

      content_definitions.present? || taggable?
    end

    # Fixes Rails partial renderer calling to_model on the object
    # which reveals the delegated element instead of this decorator.
    def respond_to?(method_name)
      return false if method_name == :to_model

      super
    end

    # Returns a deprecation notice for elements marked deprecated
    #
    # You can either use localizations or pass a String as notice
    # in the element definition.
    #
    # == Custom deprecation notices
    #
    # Use general element deprecation notice
    #
    #     - name: old_element
    #       deprecated: true
    #
    # Add a translation to your locale file for a per element notice.
    #
    #     en:
    #       alchemy:
    #         element_deprecation_notices:
    #           old_element: Foo baz widget is deprecated
    #
    # or use the global translation that apply to all deprecated elements.
    #
    #     en:
    #       alchemy:
    #         element_deprecation_notice: Foo baz widget is deprecated
    #
    # or pass string as deprecation notice.
    #
    #     - name: old_element
    #       deprecated: This element will be removed soon.
    #
    def deprecation_notice
      case definition["deprecated"]
      when String
        definition["deprecated"]
      when TrueClass
        Alchemy.t(name,
                  scope: :element_deprecation_notices,
                  default: Alchemy.t(:element_deprecated))
      end
    end
  end
end
