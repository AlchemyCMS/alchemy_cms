# frozen_string_literal: true

namespace :alchemy do
  namespace :generate do
    desc "Generates all thumbnails for Alchemy Pictures and Picture Ingredients."
    task thumbnails: [
      "alchemy:generate:picture_thumbnails",
      "alchemy:generate:ingredient_picture_thumbnails"
    ]

    desc "Generates thumbnails for Alchemy Pictures."
    task picture_thumbnails: :environment do
      puts "Generating thumbnails for #{Alchemy::Picture.count} pictures..."

      Alchemy::GenerateThumbnails.pictures { print "." }

      puts "\nDone!"
    end

    desc "Generates thumbnails for Alchemy Picture Ingredients (set ELEMENTS=element1,element2 to only generate thumbnails for a subset of elements)."
    task ingredient_picture_thumbnails: :environment do
      element_names = ENV["ELEMENTS"].presence&.split(",")

      puts "Generating thumbnails for picture ingredients..."

      count = 0
      Alchemy::GenerateThumbnails.ingredients(element_names: element_names) do
        count += 1
        print "."
      end

      puts "\nGenerated thumbnails for #{count} picture ingredients. Done!"
    end
  end
end
