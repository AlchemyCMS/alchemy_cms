require 'rails'

module Alchemy
  module Generators
    class GalleryPicturesMigrationGenerator < ::Rails::Generators::Base
      desc "This generator generates a script to update your elements to gallery pictures."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def append_into_seeds
        append_file Rails.root.join("db/seeds.rb") do
          <<-BLAH

module Alchemy

  # Add all element names that contain a single picture.
  Element.named(["picture", "background"]).each do |element|
    element.contents.essence_pictures.each do |content|
      content.update_column(:name, "image")
    end
  end

  # Add all element names that contain a picture gallery.
  Element.named(["gallery", "slides"]).each do |element|
    element.contents.essence_pictures.each_with_index do |content, i|
      content.update_column(:name, "essence_picture_#\{i+1\}")
    end
  end

end
BLAH
        end
      end

      def display_todo
        say "\nNow please alter `db/seeds.rb` so that it contains the elements you want to convert.\n"
      end

    end
  end
end
