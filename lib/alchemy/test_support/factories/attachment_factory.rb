# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_attachment, class: "Alchemy::Attachment" do
    transient do
      file do
        Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png")
      end
    end

    after(:build) do |picture, acc|
      if acc.file
        picture.file.attach(
          io: File.open(acc.file),
          filename: File.basename(acc.file),
          content_type: MiniMime.lookup_by_extension(File.extname(acc.file).remove("."))&.content_type || "application/octet-stream",
          identify: false,
        )
      end
    end

    name { "image" }
    file_name { "image.png" }
  end
end
