# frozen_string_literal: true

module Alchemy
  module DragonflyToImageProcessing
    RESIZE_TO_LIMIT = />$/
    RESIZE_TO_FILL = /\#$/
    RESIZE_TO_FIT = /\^$/
    NOSHARPEN = {sharpen: false}.freeze

    class << self
      def call(options = {})
        opts = crop_options(options).presence || resize_options(options)
        opts.merge!(format_options(options))
        opts.merge!(flatten_options(options))
        opts.merge!(quality_options(options))
        opts
      end

      private

      def crop_options(options)
        return {} unless options[:crop] && options[:crop_from] && options[:crop_size] && options[:size]

        crop_from = options[:crop_from].split("x", 2).map(&:to_i)
        crop_size = options[:crop_size].split("x", 2).map(&:to_i)
        {
          crop: crop_from + crop_size
        }.merge(resize_options(options.except(:crop)))
      end

      def resize_options(options)
        return {} unless options[:size]

        size_string = image_magick_string(options)
        width, height = size_string.split("x", 2).map(&:to_i)
        case size_string
        when RESIZE_TO_FIT
          resize_to_fit_options(width, height)
        when RESIZE_TO_FILL
          resize_to_fill_options(width, height)
        else
          resize_to_limit_options(width, height)
        end.transform_values! do |value|
          value.push(sharpen_option(options))
        end
      end

      def quality_options(options)
        quality = options[:quality] || Alchemy.config.get(:output_image_quality)
        {saver: {quality: quality}}
      end

      def format_options(options)
        format = options[:format] || default_output_format
        return {} if format.nil?

        {format: format}
      end

      def flatten_options(options)
        case options[:flatten]
        when true
          {loader: flattened_loader_options}
        when false, nil
          {loader: not_flattened_loader_options}
        end
      end

      def flattened_loader_options
        case variant_processor
        when :vips
          {n: 1}
        when :mini_magick
          {page: 0}
        end
      end

      def not_flattened_loader_options
        case variant_processor
        when :vips
          {n: -1}
        when :mini_magick
          {page: nil}
        end
      end

      def image_magick_string(options)
        if options[:crop] == true
          "#{options[:size]}#"
        else
          options[:size]
        end
      end

      def resize_to_fit_options(width, height)
        {
          resize_to_fit: [width, height]
        }
      end

      def resize_to_fill_options(width, height)
        {
          resize_to_fill: [width, height]
        }
      end

      def resize_to_limit_options(width, height)
        {
          resize_to_limit: [width, height]
        }
      end

      def sharpen_option(options)
        sharpen_value(options) ? {} : NOSHARPEN
      end

      def sharpen_value(options)
        options.key?(:sharpen) ? options[:sharpen] : Alchemy.config.get(:sharpen_images)
      end

      def default_output_format
        return nil if Alchemy::Config.get(:image_output_format) == "original"

        Alchemy::Config.get(:image_output_format)
      end

      def variant_processor
        Rails.application.config.active_storage.variant_processor
      end
    end
  end
end
