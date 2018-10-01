require 'factory_bot'

FactoryBot.define do
  factory :alchemy_element, class: 'Alchemy::Element' do
    name { 'article' }
    create_contents_after_create { false }
    association :page, factory: :alchemy_page

    trait :unique do
      unique { true }
      name { 'header' }
    end

    trait :with_nestable_elements do
      name { 'slider' }
    end

    trait :nested do
      association :parent_element, factory: :alchemy_element, name: 'slider'
      name { 'slide' }
    end

    trait :with_contents do
      create_contents_after_create { true }
    end
  end
end
