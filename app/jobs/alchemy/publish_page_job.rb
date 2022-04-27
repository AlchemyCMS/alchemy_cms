# frozen_string_literal: true

module Alchemy
  class PublishPageJob < BaseJob
    queue_as :default

    def perform(page_id, public_on:)
      page = Alchemy::Page.includes(
        Alchemy::EagerLoading.page_includes(version: :draft_version)
      ).find(page_id)
      Alchemy::Page::Publisher.new(page).publish!(public_on: public_on)
    end
  end
end
