require 'factory_girl'

FactoryGirl.define do

  factory :alchemy_element, class: 'Alchemy::Element' do
    name 'article'
    create_contents_after_create false

    trait :unique do
      unique true
      name 'header'
    end

    trait :with_nestable_elements do
      name 'slider'
    end

    trait :with_contents do
      create_contents_after_create true
    end
  end
end
