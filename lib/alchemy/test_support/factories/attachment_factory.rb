# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_attachment, class: "Alchemy::Attachment" do
    transient do
      file do
        Rack::Test::UploadedFile.new(
          Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png")
        )
      end
    end

    after(:build) do |attachment, acc|
      if acc.file
        attachment.file = acc.file
      end
    end

    name { "image" }
    file_name { "image.png" }
  end
end
