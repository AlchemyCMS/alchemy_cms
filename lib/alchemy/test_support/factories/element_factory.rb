# frozen_string_literal: true

require "factory_bot"
require "alchemy/test_support/factories/page_factory"

FactoryBot.define do
  factory :alchemy_element, class: "Alchemy::Element" do
    name { "article" }
    autogenerate_contents { false }
    association :page, factory: :alchemy_page

    trait :fixed do
      fixed { true }
      name { "right_column" }
    end

    trait :unique do
      unique { true }
      name { "header" }
    end

    trait :trashed do
      after(:create) do |element|
        element.update_column(:position, :null)
      end
    end

    trait :with_nestable_elements do
      name { "slider" }
    end

    trait :nested do
      association :parent_element, factory: :alchemy_element, name: "slider"
      name { "slide" }
    end

    trait :with_contents do
      autogenerate_contents { true }
    end
  end
end
