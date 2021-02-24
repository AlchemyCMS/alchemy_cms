# frozen_string_literal: true

module Alchemy
  module EagerLoading
    extend ActiveSupport::Concern

    included do
      helper_method :alchemy_page_loading_includes
    end

    private

    # Eager load includes for loading alchemy pages
    def alchemy_page_loading_includes
      [{ public_version: { elements: alchemy_element_loading_includes } }]
    end

    # Eager load includes for loading alchemy elements
    def alchemy_element_loading_includes
      [
        { nested_elements: { contents: alchemy_content_loading_includes } },
        { contents: alchemy_content_loading_includes },
      ]
    end

    # Eager load includes for loading alchemy contents
    def alchemy_content_loading_includes
      [{ essence: :ingredient_association }]
    end
  end
end
