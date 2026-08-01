# frozen_string_literal: true

require "alchemy/tasks/generate_thumbnails"

namespace :alchemy do
  namespace :generate do
    desc "Generates all thumbnails for Alchemy Pictures and Picture Ingredients."
    task thumbnails: [
      "alchemy:generate:picture_thumbnails",
      "alchemy:generate:ingredient_picture_thumbnails"
    ]

    desc "Generates thumbnails for Alchemy Pictures (set ASYNC=true to enqueue them as background jobs, active_storage only)."
    task picture_thumbnails: :environment do
      async = ActiveModel::Type::Boolean.new.cast(ENV["ASYNC"]) && Alchemy.storage_adapter.active_storage?

      puts "#{async ? "Enqueuing" : "Generating"} thumbnails for #{Alchemy::Picture.count} pictures..."

      Alchemy::GenerateThumbnails.pictures(async: async) { print "." }

      puts "\nDone!"
    end

    desc "Generates thumbnails for Alchemy Picture Ingredients (set ELEMENTS=element1,element2 to only generate thumbnails for a subset of elements, set ASYNC=true to enqueue them as background jobs, active_storage only)."
    task ingredient_picture_thumbnails: :environment do
      element_names = ENV["ELEMENTS"].presence&.split(",")
      async = ActiveModel::Type::Boolean.new.cast(ENV["ASYNC"]) && Alchemy.storage_adapter.active_storage?

      puts "#{async ? "Enqueuing" : "Generating"} thumbnails for picture ingredients..."

      count = 0
      Alchemy::GenerateThumbnails.ingredients(element_names: element_names, async: async) do
        count += 1
        print "."
      end

      puts "\n#{async ? "Enqueued" : "Generated"} thumbnails for #{count} picture ingredients. Done!"
    end
  end
end
