# frozen_string_literal: true

require 'factory_bot'
require 'alchemy/test_support/factories/language_factory'
require 'alchemy/test_support/factories/page_factory'

FactoryBot.define do
  factory :alchemy_node, class: 'Alchemy::Node' do
    language { Alchemy::Language.default }

    trait :with_name do
      name { 'A Node' }
    end

    trait :with_page do
      association :page, factory: :alchemy_page
    end

    trait :with_url do
      url { 'https://example.com' }
    end
  end
end
