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
        fixed? ? "is-fixed" : "not-fixed",
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
  end
end
