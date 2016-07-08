module Alchemy
  module Picture::Url
    # Picture url for the dragonfly endpoint
    #
    # TODO: Describe options
    #
    def url(options = {})
      image = image_file

      raise MissingImageFileError, "Missing image file for #{inspect}" if image.nil?

      image = processed_image(image, options)
      image = encoded_image(image, options)
      image.url
    end

    private

    # Returns the processed image dependent of size and cropping parameters
    def processed_image(image, options = {})
      size = options[:size]
      upsample = !!options[:upsample]

      return image unless size.present? && has_convertible_format?

      if options[:crop_size].present? && options[:crop_from].present? || options[:crop].present?
        crop(size, options[:crop_from], options[:crop_size], upsample)
      else
        resize(size, upsample)
      end
    end

    def encoded_image(image, options = {})
      target_format = options[:format] || default_render_format
      raise WrongImageFormatError if !target_format.in?(Alchemy::Picture.allowed_filetypes)

      options = {
        flatten: target_format != 'gif' && image_file_format == 'gif'
      }.merge(options)

      encoding_options = []

      if target_format =~ /jpe?g/
        quality = options[:quality] || Config.get(:output_image_jpg_quality)
        encoding_options << "-quality #{quality}"
      end

      # Flatten animated gifs, only if converting to a different format.
      # Can be overwritten via +options[:flatten]+.
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
