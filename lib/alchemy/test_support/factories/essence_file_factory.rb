# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_essence_file, class: "Alchemy::EssenceFile" do
    attachment factory: :alchemy_attachment
  end
end
