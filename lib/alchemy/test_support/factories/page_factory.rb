# frozen_string_literal: true

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
      transient do
        public_on { Time.current }
        public_until { nil }
      end
      after(:build) do |page, evaluator|
        page.build_public_version(
          public_on: evaluator.public_on,
          public_until: evaluator.public_until,
        )
      end
      after(:create) do |page|
        if page.autogenerate_elements
          page.definition["autogenerate"].each do |name|
            create(:alchemy_element,
              name: name,
              page_version: page.public_version,
              autogenerate_contents: true)
          end
        end
      end
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
