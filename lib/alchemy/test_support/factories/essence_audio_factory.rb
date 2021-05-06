# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_essence_audio, class: "Alchemy::EssenceAudio" do
    attachment factory: :alchemy_attachment
  end
end
