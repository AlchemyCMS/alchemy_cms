# frozen_string_literal: true

module Alchemy
  module CacheDigests
    class TemplateTracker
      def self.call(name, template)
        new(name, template).dependencies
      end

      def initialize(name, template)
        @name, @template = name, template
      end

      def dependencies
        case @name.to_s
        when /^alchemy\/pages\/show/
          PageLayout.all.map { |p| "alchemy/page_layouts/_#{p["name"]}" }
        when /^alchemy\/page_layouts\/_(\w+)/
          page_layout = PageLayout.get($1)
          layout_elements = page_layout.fetch("elements", [])
          layout_elements.map { |name| "alchemy/elements/_#{name}_view" } +
            layout_elements.map { |name| "alchemy/elements/_#{name}" }
        when /^alchemy\/elements\/_(\w+)_view/, /^alchemy\/elements\/_(\w+)/
          essence_types($1).map { |name|
            "alchemy/essences/_#{name.underscore}_view"
          }.uniq
        else
          ActionView::DependencyTracker::ERBTracker.call(@name, @template)
        end
      end

      private

      def essence_types(name)
        element = Element.definitions.detect { |e| e["name"] == name }
        return [] unless element

        element.fetch("contents", []).collect { |c| c["type"] }
      end
    end
  end
end
