# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_element, class: "Alchemy::Element" do
    name { "article" }
    autogenerate_contents { false }
    association :page_version, factory: :alchemy_page_version

    trait :fixed do
      fixed { true }
      name { "right_column" }
    end

    trait :unique do
      unique { true }
      name { "header" }
    end

    trait :with_nestable_elements do
      name { "slider" }
    end

    trait :nested do
      parent_element { build(:alchemy_element, name: "slider", page_version: page_version) }
      name { "slide" }
    end

    trait :with_contents do
      autogenerate_contents { true }
    end
  end
end
