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
        when /alchemy\/page_layouts/
          return page_layout.fetch('elements', []).map { |name| "alchemy/elements/_#{name}_view" }
        when /alchemy\/cells/
          return cell_definition.fetch('elements', []).map { |name| "alchemy/elements/_#{name}_view" }
        else
          ActionView::DependencyTracker::ERBTracker.call(@name, @template)
        end
      end

    private

      def template_name
        @name.split('/').last.to_s.gsub(/_/, '')
      end

      def page_layout
        PageLayout.get(template_name)
      end

      def cell_definition
        Cell.definition_for(template_name)
      end

    end
  end
end
