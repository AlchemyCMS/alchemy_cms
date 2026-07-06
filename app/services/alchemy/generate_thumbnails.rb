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
  #
  # With +async: true+ the +active_storage+ variants are enqueued as
  # +ActiveStorage::TransformJob+s instead of being processed inline. The
  # +dragonfly+ adapter has no background processor and always runs inline.
  class GenerateThumbnails
    class << self
      # Pre-generates the archive thumbnails (+Alchemy::Picture::THUMBNAIL_SIZES+)
      # for every picture. These are the thumbnails used by the picture archive.
      #
      # @param async [Boolean] Enqueue active_storage variants as background jobs
      # @yield [Alchemy::Picture] each picture after it was processed / enqueued
      def pictures(async: false)
        Alchemy::Picture.find_each do |picture|
          generate_for_picture(picture, async: async)
          yield picture if block_given?
        end
      end

      # Pre-generates the thumbnails rendered for published picture ingredients.
      #
      # Takes the ingredients crop and srcset settings into account, so all
      # variants that the frontend requests are generated upfront.
      #
      # @param element_names [Array<String>, nil] Restrict to these element names
      # @param async [Boolean] Enqueue active_storage variants as background jobs
      # @yield [Alchemy::Ingredients::Picture] each ingredient after it was processed / enqueued
      def ingredients(element_names: nil, async: false)
        ingredient_scope(element_names).find_each do |ingredient|
          generate_for_ingredient(ingredient, async: async)
          yield ingredient if block_given?
        end
      end

      private

      def generate_for_picture(picture, async:)
        Alchemy::Picture::THUMBNAIL_SIZES.each_value do |size|
          preprocess(picture, {size: size, flatten: true}, async: async)
        end
      end

      def generate_for_ingredient(ingredient, async:)
        picture = ingredient.picture
        return if picture.nil?

        preprocess(picture, ingredient.picture_url_options, async: async)
        preprocess(picture, ingredient.thumbnail_url_options, async: async)
        ingredient.settings.fetch(:srcset, []).each do |size|
          preprocess(picture, ingredient.picture_url_options.merge(size: size), async: async)
        end
      end

      # Materializes a single picture variant for the given render options
      # using the configured storage adapter.
      #
      # Under +active_storage+ this processes and stores the variant inline, or
      # enqueues a native +ActiveStorage::TransformJob+ when +async+ is true.
      # Under +dragonfly+ requesting the url persists the +Alchemy::PictureThumb+.
      def preprocess(picture, options, async: false)
        return unless picture&.has_convertible_format?

        if Alchemy.storage_adapter.active_storage?
          transformations = Alchemy::DragonflyToImageProcessing.call(options)
          if async
            ActiveStorage::TransformJob.perform_later(picture.image_file.blob, transformations)
          else
            picture.image_file.variant(transformations).processed
          end
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
