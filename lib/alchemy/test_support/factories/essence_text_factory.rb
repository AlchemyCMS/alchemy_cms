# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_essence_text, class: "Alchemy::EssenceText" do
    body { "This is a headline" }
  end
end
