# frozen_string_literal: true

module Alchemy
  class PublishPageJob < BaseJob
    queue_as :default

    def perform(page, public_on:)
      Alchemy::Page::Publisher.new(page).publish!(public_on: public_on)
    end
  end
end
