# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_picture, class: "Alchemy::Picture" do
    transient do
      image_file do
        Rack::Test::UploadedFile.new(
          Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png")
        )
      end
    end

    after(:build) do |picture, acc|
      if acc.image_file
        picture.image_file = acc.image_file
      end
    end

    name { "image" }
    upload_hash { Time.current.hash }
  end
end
