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
          PageDefinition.all.map { "alchemy/page_layouts/_#{_1.name}" }
        when /^alchemy\/page_layouts\/_(\w+)/
          page_definition = PageDefinition.get($1)
          page_definition.elements.map { "alchemy/elements/_#{_1}" }
        when /^alchemy\/elements\/_(\w+)/
          ingredient_types($1).map { "alchemy/ingredients/_#{_1.underscore}_view" }.tap(&:uniq!)
        else
          ActionView::DependencyTracker::ERBTracker.call(@name, @template)
        end
      end

      private

      def ingredient_types(name)
        element = Element.definitions.detect { _1.name == name }
        return [] unless element

        element.ingredients.map { _1["type"] }
      end
    end
  end
end
