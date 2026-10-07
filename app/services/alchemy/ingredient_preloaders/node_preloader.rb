# frozen_string_literal: true

module Alchemy
  module IngredientPreloaders
    # Preloads the +:page+ and +:children+ associations on +Alchemy::Node+ records
    # that are the +related_object+ of +Alchemy::Ingredients::Node+ ingredients.
    #
    # Fires two queries:
    #   SELECT … FROM alchemy_pages WHERE id IN (…)          -- for :page
    #   SELECT … FROM alchemy_nodes WHERE parent_id IN (…)   -- for :children
    #
    # +:page+ is accessed by +Node#name+ (falls back to +page.name+ when no
    # explicit name is set) and by +Node#url+ (delegates to +page.url_path+).
    #
    # +:children+ is accessed in standard menu partials via +node.children.any?+.
    # Without preloading this produces one query per rendered node.
    #
    # @example Wired in automatically via Alchemy.config.ingredient_preloaders
    class NodePreloader
      # @param nodes [Array<Alchemy::Node>]
      def self.call(nodes)
        return if nodes.blank?

        ActiveRecord::Associations::Preloader.new(
          records: nodes,
          associations: [:page, :children]
        ).call
      end
    end
  end
end
