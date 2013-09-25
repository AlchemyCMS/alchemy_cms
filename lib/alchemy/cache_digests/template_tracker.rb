module Alchemy
  module CacheDigests
    class TemplateTracker

      def self.call(name, template)
        deps = new(name, template).dependencies
        Rails.logger.info "++++ dependencies: #{deps}"
        deps
      end

      def initialize(name, template)
        @name, @template = name, template
      end

      def dependencies
        debugger
        case @name.to_s
        when /alchemy\/page_layouts/ # TODO: refactor this to have a regexp match group ($1)
          return page_layout.fetch('elements', []).map { |name| "alchemy/elements/_#{name}_view" }
        # TODO: Get the element essences template dependencies working
        # when /alchemy\/elements\/_(.+)_view\.html/
        #   essences = essence_types($1)
        #   if element_description($1)['picture_gallery']
        #     essences += ['alchemy/essences/essence_picture_view']
        #   end
        #   return essences.map { |name| "alchemy/essences/_#{name}_view" }
        when /alchemy\/cells/
          return cell_definition.fetch('elements', []).map { |name| "alchemy/elements/_#{name}_view" }
          # TODO: do the same with element dependencies like in elements
        else
          ActionView::DependencyTracker::ERBTracker.call(@name, @template)
        end
      end

    private

      # TODO: refactor this to use regexp match group ($1)
      def template_name
        @name.split('/').last.to_s.gsub(/_/, '')
      end

      def page_layout
        PageLayout.get(template_name)
      end

      def cell_definition
        Cell.definition_for(template_name)
      end

      def element_description(name)
        Element.descriptions.detect { |e| e['name'] == name }
      end

      def essence_types(name)
        if element = element_description(name)
          element.fetch('contents', {}).collect { |c| c['type'] }
        else
          []
        end
      end

    end
  end
end
