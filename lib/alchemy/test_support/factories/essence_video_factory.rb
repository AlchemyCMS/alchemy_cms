# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_essence_video, class: "Alchemy::EssenceVideo" do
    attachment factory: :alchemy_attachment
  end
end
