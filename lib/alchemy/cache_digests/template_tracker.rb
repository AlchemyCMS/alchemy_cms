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
          PageLayout.all.collect { |p| "alchemy/page_layouts/_#{p['name']}" }
        when /^alchemy\/page_layouts\/_(.+)/
          page_layout = page_layout($1)
          element_templates(page_layout) +
            page_layout.fetch('cells', []).map { |name| "alchemy/cells/_#{name}" }
        when /^alchemy\/cells\/_(.+)/
          element_templates cell_definition($1)
        when /alchemy\/elements\/_(.+)_view/
          essences = essence_types($1)
          element = element_definition($1)
          if element && element['picture_gallery']
            essences += ['EssencePicture']
          end
          essences.map { |name| "alchemy/essences/_#{name.underscore}_view" }.uniq
        else
          ActionView::DependencyTracker::ERBTracker.call(@name, @template)
        end
      end

      private

      def element_templates(collection)
        collection.fetch('elements', []).map { |name| "alchemy/elements/_#{name}_view" }
      end

      def page_layout(name)
        PageLayout.get(name)
      end

      def cell_definition(name)
        Cell.definition_for(name)
      end

      def element_definition(name)
        Element.definitions.detect { |e| e['name'] == name }
      end

      def essence_types(name)
        element = element_definition(name)
        return [] unless element
        element.fetch('contents', []).collect { |c| c['type'] }
      end
    end
  end
end
