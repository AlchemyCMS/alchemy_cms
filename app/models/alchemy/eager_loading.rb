# frozen_string_literal: true

module Alchemy
  # Eager loading parameters for loading pages
  class EagerLoading
    PAGE_VERSIONS = %i[draft_version public_version]

    class << self
      # Eager loading parameters for {ActiveRecord::Base.includes}
      #
      # Pass this to +includes+ whereever you load an {Alchemy::Page}
      #
      #     Alchemy::Page.includes(Alchemy::EagerLoading.page_includes).find_by(urlname: "my-page")
      #
      # @param version [Symbol] Type of page version to eager load
      # @return [Array]
      def page_includes(version: :public_version)
        raise UnsupportedPageVersion unless version.in? PAGE_VERSIONS

        [
          :tags,
          {
            language: :site,
            version => {
              elements: [
                :page,
                :touchable_pages,
                {
                  ingredients: :related_object,
                  contents: :essence,
                },
              ],
            },
          },
        ]
      end
    end
  end
end
