# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_node, class: "Alchemy::Node" do
    language { Alchemy::Language.default || create(:alchemy_language) }
    name { "A Node" }
    menu_type { Alchemy::Node.available_menu_names.first }

    trait :with_page do
      association :page, factory: :alchemy_page
      name { nil }
    end

    trait :with_url do
      url { "https://example.com" }
    end
  end
end
