# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_picture, class: "Alchemy::Picture" do
    image_file do
      File.new(Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png"))
    end
    name { "image" }
    upload_hash { Time.current.hash }
  end
end
