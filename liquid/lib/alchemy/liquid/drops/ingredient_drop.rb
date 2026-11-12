# frozen_string_literal: true

module Alchemy
  module Liquid
    module Drops
      # Exposes an Alchemy::Ingredient to Liquid templates.
      #
      #   {{ ingredient.value }}
      #   {{ ingredient.role }}
      #   {{ ingredient.link_title }}
      #
      # Besides the attributes below, every attribute an ingredient stores in
      # its +data+ column is readable (e.g. +alt_tag+, +caption+, +link+ or
      # +level+, depending on the type).
      #
      # To render an ingredient as markup use the +ingredient+ tag instead.
      class IngredientDrop < Base
        def role
          record.role
        end

        # The demodulized type, e.g. "Text" or "Picture".
        def type
          record.class.name.demodulize
        end

        # The ingredient's value. Text is HTML escaped; related pages and
        # nodes are returned as drops. Other related objects (pictures,
        # attachments) are not exposed, use the filters or the
        # +ingredient+ tag for those.
        def value
          escape(drop(record.value))
        end

        # True if the ingredient has a value.
        #
        #   {% if element.ingredients.headline.present %}
        def present
          record.value.present?
        end

        # Used by Liquid for +== blank+ and +== empty+ comparisons.
        def blank?
          !present
        end
        alias_method :empty?, :blank?

        def liquid_method_missing(name)
          if data_attributes.include?(name.to_s)
            escape(record.public_send(name))
          else
            super
          end
        end

        private

        def data_attributes
          record.class.stored_attributes.fetch(:data, []).map(&:to_s)
        end
      end
    end
  end
end
