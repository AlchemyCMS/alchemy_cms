# frozen_string_literal: true

require "factory_bot"
require "alchemy/test_support/factories/page_factory"

FactoryBot.define do
  factory :alchemy_page_version, class: "Alchemy::PageVersion" do
    association :page, factory: :alchemy_page

    trait :published do
      public_on { Time.current }
    end
  end
end
