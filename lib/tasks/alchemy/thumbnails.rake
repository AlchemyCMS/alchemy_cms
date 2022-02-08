# frozen_string_literal: true

namespace :alchemy do
  namespace :generate do
    desc "Generates all thumbnails for Alchemy Pictures and EssencePictures."
    task thumbnails: [
      "alchemy:generate:picture_thumbnails",
      "alchemy:generate:essence_picture_thumbnails",
    ]

    desc "Generates thumbnails for Alchemy Pictures."
    task picture_thumbnails: :environment do
      puts "Regenerate #{Alchemy::Picture.count} picture thumbnails."
      puts "Please wait..."

      Alchemy::Picture.find_each do |picture|
        next unless picture.has_convertible_format?

        puts Alchemy::PictureThumb.generate_thumbs!(picture)
      end

      puts "Done!"
    end

    desc "Generates thumbnails for Alchemy EssencePictures."
    task essence_picture_thumbnails: :environment do
      essence_pictures = Alchemy::EssencePicture.joins(:content, :ingredient_association)
      puts "Regenerate #{essence_pictures.count} essence picture thumbnails."
      puts "Please wait..."

      essence_pictures.find_each do |essence_picture|
        puts essence_picture.picture_url
        puts essence_picture.thumbnail_url
      end

      puts "Done!"
    end
  end
end
