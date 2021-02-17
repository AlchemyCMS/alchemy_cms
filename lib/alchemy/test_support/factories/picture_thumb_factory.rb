# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_picture_thumb, class: "Alchemy::PictureThumb" do
    picture { create(:alchemy_picture) }
    signature { SecureRandom.hex(16) }
    sequence(:uid) { |n| "#{Time.now.strftime("%Y/%m/%d")}/#{n}.jpg" }
  end
end
