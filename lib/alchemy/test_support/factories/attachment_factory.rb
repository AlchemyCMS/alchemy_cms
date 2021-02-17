# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_attachment, class: "Alchemy::Attachment" do
    file do
      File.new(Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png"))
    end
    name { "image" }
    file_name { "image.png" }
  end
end
