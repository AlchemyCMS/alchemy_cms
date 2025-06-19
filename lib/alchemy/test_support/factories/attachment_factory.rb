# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_attachment, class: "Alchemy::Attachment" do
    transient do
      file do
        Rack::Test::UploadedFile.new(
          Alchemy::Engine.root.join("spec", "fixtures", "files", "image.png")
        )
      end
    end

    after(:build) do |attachment, acc|
      if acc.file
        case Alchemy.storage_adapter.name
        when :active_storage
          attachment.file.attach(
            io: acc.file,
            filename: acc.file.original_filename,
            content_type: MiniMime.lookup_by_extension(
              File.extname(acc.file.original_filename).remove(".")
            )&.content_type || "application/octet-stream",
            identify: false
          )
        when :dragonfly
          attachment.file = acc.file
        end
      end
    end

    name { "image" }
    file_name { "image.png" }
  end
end
