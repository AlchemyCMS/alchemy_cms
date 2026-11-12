# frozen_string_literal: true

module Alchemy
  module Liquid
    module Drops
      # Exposes an Alchemy::Node (a menu entry) to Liquid templates.
      #
      #   {% for child in node.children %}
      #     <a href="{{ child.url }}">{{ child.name }}</a>
      #   {% endfor %}
      class NodeDrop < Base
        def name
          escape(record.name)
        end

        def title
          escape(record.title)
        end

        # Either the attached page's path or the external url.
        def url
          record.url
        end

        def nofollow
          !!record.nofollow
        end

        def external
          !!record.external
        end

        def menu_type
          record.menu_type
        end

        def page
          drop(record.page)
        end

        def children
          @children ||= record.children.map { NodeDrop.new(_1) }
        end
      end
    end
  end
end
