# frozen_string_literal: true

module Alchemy
  module IngredientPreloaders
    # Preloads the +:language+ association on +Alchemy::Page+ records that are
    # the +related_object+ of +Alchemy::Ingredients::Page+ ingredients.
    #
    # Fires one query:
    #   SELECT … FROM alchemy_languages WHERE id IN (…)
    #
    # This covers customized +url_path_class+ implementations that include the
    # language in the URL (e.g. language-prefixed paths), where accessing
    # +page.language+ without preloading would produce one query per page.
    #
    # @example Wired in automatically via Alchemy.config.ingredient_preloaders
    class PagePreloader
      # @param pages [Array<Alchemy::Page>]
      def self.call(pages)
        return if pages.blank?

        ActiveRecord::Associations::Preloader.new(
          records: pages,
          associations: :language
        ).call
      end
    end
  end
end
