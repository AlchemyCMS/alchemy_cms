# frozen_string_literal: true

require "factory_bot"
require "alchemy/test_support/factories/language_factory"

FactoryBot.define do
  factory :alchemy_page, class: "Alchemy::Page" do
    language do
      @cached_attributes[:parent]&.language ||
        Alchemy::Language.default ||
        FactoryBot.create(:alchemy_language)
    end
    sequence(:name) { |n| "A Page #{n}" }
    page_layout { "standard" }

    parent do
      Alchemy::Page.find_by(language_root: true, language: language) ||
        FactoryBot.create(:alchemy_page, :language_root, language: language)
    end

    # This speeds up creating of pages dramatically.
    # Pass autogenerate_elements: true to generate elements
    autogenerate_elements { false }

    trait :language_root do
      name { language&.frontpage_name || "Intro" }
      page_layout { language&.page_layout || "index" }
      language_root { true }
      public_on { Time.current }
      parent { nil }
    end

    trait :public do
      sequence(:name) { |n| "A Public Page #{n}" }
      public_on { Time.current }
    end

    trait :layoutpage do
      parent { nil }
      layoutpage { true }
      page_layout { "footer" }
    end

    trait :restricted do
      name { "Restricted page" }
      restricted { true }
    end

    trait :locked do
      locked_at { Time.current }
      locked_by { SecureRandom.random_number(1_000_000_000) }
    end
  end
end
