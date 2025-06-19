# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_picture, class: "Alchemy::Picture" do
    transient do
      image_file do
        File.new(Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png"))
      end
    end

    after(:build) do |picture, acc|
      if acc.image_file
        case Alchemy.storage_adapter.name
        when :active_storage
          picture.image_file.attach(
            io: File.open(acc.image_file),
            filename: File.basename(acc.image_file),
            content_type: MiniMime.lookup_by_extension(File.extname(acc.image_file).remove("."))&.content_type || "application/octet-stream",
            identify: false
          )
        when :dragonfly
          picture.image_file = acc.image_file
          picture.image_file_name = acc.image_file_name
          picture.image_file_size = acc.image_file.size
        end
      end
    end

    name { "image" }
    upload_hash { Time.current.hash }
  end
end
