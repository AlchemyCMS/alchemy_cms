module Alchemy
  module Admin
    class PictureDescriptionSelect < ViewComponent::Base
      erb_template <<-ERB
        <alchemy-picture-description-select url="<%= url %>">
          <label class="inline-label">
            <%= label %>
            <%= select name_prefix, :language_id,
              options_for_select(language_options, selected:) %>
          </label>
        </alchemy-picture-description-select>
      ERB

      def initialize(url:, selected:, name_prefix:)
        @url = url
        @selected = selected
        @name_prefix = name_prefix
      end

      def render?
        Alchemy::Language.published.many?
      end

      private

      delegate :multi_site?, to: :helpers

      attr_reader :name_prefix, :selected, :url

      def label
        Alchemy::Language.model_name.human
      end

      def language_options
        Alchemy::Language.published.map do |language|
          [language_label(language), language.id]
        end
      end

      def language_label(language)
        language_name = language.name
        multi_site? ? "#{language_name} (#{language.site.name})" : language_name
      end
    end
  end
end
