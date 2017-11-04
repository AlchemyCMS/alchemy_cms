# frozen_string_literal: true

module Alchemy
  module Picture::Url
    include Alchemy::Logger

    TRANSFORMATION_OPTIONS = [
      :crop,
      :crop_from,
      :crop_size,
      :flatten,
      :format,
      :quality,
      :size,
      :upsample
    ]

    # Returns a path to picture for use inside a image_tag helper.
    #
    # Any additional options are passed to the url_helper, so you can add arguments to your url.
    #
    # Example:
    #
    #   <%= image_tag picture.url(size: '320x200', format: 'png') %>
    #
    def url(options = {})
      image = image_file

      raise MissingImageFileError, "Missing image file for #{inspect}" if image.nil?

      image = processed_image(image, options)
      image = encoded_image(image, options)

      image.url(options.except(*TRANSFORMATION_OPTIONS).merge(name: name))
    rescue MissingImageFileError, WrongImageFormatError => e
      log_warning e.message
      nil
    end

    private

    # Returns the processed image dependent of size and cropping parameters
    def processed_image(image, options = {})
      size = options[:size]
      upsample = !!options[:upsample]

      return image unless size.present? && has_convertible_format?

      if options[:crop]
        crop(size, options[:crop_from], options[:crop_size], upsample)
      else
        resize(size, upsample)
      end
    end

    # Returns the encoded image
    #
    # Flatten animated gifs, only if converting to a different format.
    # Can be overwritten via +options[:flatten]+.
    #
    def encoded_image(image, options = {})
      target_format = options[:format] || default_render_format

      unless target_format.in?(Alchemy::Picture.allowed_filetypes)
        raise WrongImageFormatError.new(self, target_format)
      end

      options = {
        flatten: target_format != 'gif' && image_file_format == 'gif'
      }.merge(options)

      encoding_options = []

      if target_format =~ /jpe?g/
        quality = options[:quality] || Config.get(:output_image_jpg_quality)
        encoding_options << "-quality #{quality}"
      end

      if options[:flatten]
        encoding_options << '-flatten'
      end

      convertion_needed = target_format != image_file_format || encoding_options.present?

      if has_convertible_format? && convertion_needed
        image = image.encode(target_format, encoding_options.join(' '))
      end

      image
    end
  end
end
