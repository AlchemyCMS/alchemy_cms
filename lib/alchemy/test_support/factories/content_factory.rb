# frozen_string_literal: true

require "factory_bot"
require "alchemy/test_support/factories/element_factory"
require "alchemy/test_support/factories/essence_file_factory"
require "alchemy/test_support/factories/essence_picture_factory"
require "alchemy/test_support/factories/essence_text_factory"

FactoryBot.define do
  factory :alchemy_content, class: "Alchemy::Content" do
    name { "text" }
    essence_type { "Alchemy::EssenceText" }
    association :essence, factory: :alchemy_essence_text
    association :element, factory: :alchemy_element

    trait :essence_file do
      essence_type { "Alchemy::EssenceFile" }
      association :essence, factory: :alchemy_essence_file
    end

    trait :essence_picture do
      essence_type { "Alchemy::EssencePicture" }
      association :essence, factory: :alchemy_essence_picture
    end
  end
end
