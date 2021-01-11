# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_page_version, class: "Alchemy::PageVersion" do
    association :page, factory: :alchemy_page

    trait :published do
      public_on { Time.current }
    end

    transient do
      element_count { 1 }
    end

    trait :with_elements do
      after(:build) do |page_version, evaluator|
        evaluator.element_count.times do
          page_version.elements.build(name: "article")
        end
      end
    end
  end
end
