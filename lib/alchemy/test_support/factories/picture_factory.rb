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
        case Alchemy.storage_adapter.name
        when :active_storage
          filename = acc.image_file.original_filename
          content_type = Marcel::MimeType.for(extension: File.extname(filename))
          picture.image_file.attach(
            io: acc.image_file.open,
            filename:,
            content_type:,
            identify: false,
            metadata: {
              width: 1,
              height: 1
            }
          )
        when :dragonfly
          picture.image_file = acc.image_file
          picture.image_file_size = acc.image_file.size
        end
      end
    end

    name { "image" }
    upload_hash { Time.current.hash }
  end
end
