# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_essence_page, class: "Alchemy::EssencePage" do
    page factory: :alchemy_page
  end
end
