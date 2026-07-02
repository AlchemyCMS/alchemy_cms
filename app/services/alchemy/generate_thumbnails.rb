# frozen_string_literal: true

module Alchemy
  # Pre-generates picture thumbnails so they do not have to be rendered
  # on the first request.
  #
  # Used by the +alchemy:generate:thumbnails+ rake tasks. Works with both
  # the +active_storage+ and the +dragonfly+ storage adapter.
  #
  # Both methods yield each processed record, so callers (like the rake task)
  # can report progress without this service having to know about the shell.
  class GenerateThumbnails
    class << self
      # Pre-generates the archive thumbnails (+Alchemy::Picture::THUMBNAIL_SIZES+)
      # for every picture. These are the thumbnails used by the picture archive.
      #
      # @yield [Alchemy::Picture] each picture after its thumbnails were generated
      def pictures
        Alchemy::Picture.find_each do |picture|
          Alchemy::Picture::THUMBNAIL_SIZES.each_value do |size|
            preprocess(picture, size: size, flatten: true)
          end
          yield picture if block_given?
        end
      end

      # Pre-generates the thumbnails rendered for published picture ingredients.
      #
      # Takes the ingredients crop and srcset settings into account, so all
      # variants that the frontend requests are generated upfront.
      #
      # @param element_names [Array<String>, nil] Restrict to these element names
      # @yield [Alchemy::Ingredients::Picture] each ingredient after its thumbnails were generated
      def ingredients(element_names: nil)
        ingredient_scope(element_names).find_each do |ingredient|
          generate_for_ingredient(ingredient)
          yield ingredient if block_given?
        end
      end

      private

      def generate_for_ingredient(ingredient)
        picture = ingredient.picture
        return if picture.nil?

        preprocess(picture, ingredient.picture_url_options)
        preprocess(picture, ingredient.thumbnail_url_options)
        ingredient.settings.fetch(:srcset, []).each do |size|
          preprocess(picture, ingredient.picture_url_options.merge(size: size))
        end
      end

      # Materializes a single picture variant for the given render options
      # using the configured storage adapter.
      #
      # Under +active_storage+ this processes and stores the variant, under
      # +dragonfly+ requesting the url persists the +Alchemy::PictureThumb+.
      #
      # Failures are reported to +Alchemy::ErrorTracking+ so a single broken
      # image can not abort a long running generation run.
      def preprocess(picture, options)
        return unless picture&.has_convertible_format?

        if Alchemy.storage_adapter.active_storage?
          transformations = Alchemy::DragonflyToImageProcessing.call(options)
          picture.image_file.variant(transformations).processed
        else
          picture.url(options)
        end
      rescue => error
        Alchemy::ErrorTracking.notification_handler.call(error)
        nil
      end

      def ingredient_scope(element_names)
        scope = Alchemy::Ingredients::Picture
          .joins(:element)
          .preload(:related_object)
          .merge(Alchemy::Element.published)
        return scope if element_names.blank?

        scope.merge(Alchemy::Element.named(element_names))
      end
    end
  end
end
