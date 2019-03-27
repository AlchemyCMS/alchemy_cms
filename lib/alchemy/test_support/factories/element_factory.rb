require 'factory_bot'

FactoryBot.define do
  factory :alchemy_element, class: 'Alchemy::Element' do
    name { 'article' }
    autogenerate_contents { false }
    association :page, factory: :alchemy_page

    trait :fixed do
      fixed { true }
      name { 'right_column' }
    end

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
      autogenerate_contents { true }
    end
  end
end
