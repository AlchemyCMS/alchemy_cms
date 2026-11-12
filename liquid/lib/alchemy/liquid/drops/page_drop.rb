# frozen_string_literal: true

module Alchemy
  module Liquid
    module Drops
      # Exposes an Alchemy::Page to Liquid templates.
      #
      #   <a href="{{ page.url }}">{{ page.name }}</a>
      class PageDrop < Base
        def name
          escape(record.name)
        end

        def title
          escape(record.title)
        end

        def urlname
          record.urlname
        end

        # The page's path, as returned by +Alchemy::Page#url_path+.
        def url
          record.url_path
        end

        def page_layout
          record.page_layout
        end

        def language_code
          record.language_code
        end

        def meta_description
          escape(record.meta_description)
        end

        def meta_keywords
          escape(record.meta_keywords)
        end

        def published_at
          record.published_at
        end

        def public_on
          record.public_on
        end

        def parent
          drop(record.parent)
        end
      end
    end
  end
end
