# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_page_version, class: "Alchemy::PageVersion" do
    association :page, factory: :alchemy_page

    trait :published do
      public_on { Time.current }
    end
  end
end
