# frozen_string_literal: true

require "factory_bot"
require "alchemy/test_support/factories/page_factory"

FactoryBot.define do
  factory :alchemy_page_version, class: "Alchemy::PageVersion" do
    association :page, factory: :alchemy_page
  end
end
