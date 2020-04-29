# frozen_string_literal: true

require "factory_bot"
require "alchemy/test_support/factories/content_factory"
require "alchemy/test_support/factories/picture_factory"

FactoryBot.define do
  factory :alchemy_essence_picture, class: "Alchemy::EssencePicture" do
    picture factory: :alchemy_picture

    trait :with_content do
      association :content, factory: :alchemy_content
    end
  end
end
