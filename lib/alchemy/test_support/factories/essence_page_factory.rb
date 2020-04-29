# frozen_string_literal: true

require "factory_bot"
require "alchemy/test_support/factories/page_factory"

FactoryBot.define do
  factory :alchemy_essence_page, class: "Alchemy::EssencePage" do
    page factory: :alchemy_page
  end
end
