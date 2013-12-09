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
          return PageLayout.all.collect { |p| "alchemy/page_layouts/_#{p['name']}" }
        when /^alchemy\/page_layouts\/_(.+)/
          page_layout = page_layout($1)
          return element_templates(page_layout) +
            page_layout.fetch('cells', []).map { |name| "alchemy/cells/_#{name}" }
        when /^alchemy\/cells\/_(.+)/
          return element_templates cell_definition($1)
        when /alchemy\/elements\/_(.+)_view/
          essences = essence_types($1)
          element = element_description($1)
          if element && element['picture_gallery']
            essences += ['EssencePicture']
          end
          return essences.map { |name| "alchemy/essences/_#{name.underscore}_view" }.uniq
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

      def element_description(name)
        Element.descriptions.detect { |e| e['name'] == name }
      end

      def essence_types(name)
        element = element_description(name)
        if element
          (element.fetch('contents', []) +
            element.fetch('available_contents', [])).collect { |c| c['type'] }
        else
          []
        end
      end

    end
  end
end
