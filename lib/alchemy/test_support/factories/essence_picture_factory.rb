# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_essence_picture, class: "Alchemy::EssencePicture" do
    picture factory: :alchemy_picture

    trait :with_content do
      association :content, factory: :alchemy_content
    end
  end
end
