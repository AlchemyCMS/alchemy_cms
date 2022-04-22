# frozen_string_literal: true

module Alchemy
  class PublishPageJob < BaseJob
    queue_as :default

    def perform(page, public_on:)
      page = Alchemy::Page.includes(
        :tags,
        language: :site,
        draft_version: {
          elements: [
            :page,
            :touchable_pages,
            {
              ingredients: :related_object,
              contents: :essence,
            },
          ],
        },
      ).find(page.id)
      Alchemy::Page::Publisher.new(page).publish!(public_on: public_on)
    end
  end
end
