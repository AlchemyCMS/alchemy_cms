module Alchemy
  class PicturesController < Alchemy::BaseController
    ALLOWED_IMAGE_TYPES = %w(png jpeg gif)

    caches_page :show, :thumbnail, :zoom

    before_filter :ensure_secure_params

    load_and_authorize_resource

    def show
      @size = params[:size]
      expires_in 1.month, public: !@picture.restricted?
      respond_to { |format| send_image(processed_image, format) }
    end

    def thumbnail
      case params[:size]
        when 'small'  then @size = '80x60'
        when 'medium' then @size = '160x120'
        when 'large'  then @size = '240x180'
        when nil      then @size = '111x93'
      else
        @size = params[:size]
      end

      respond_to { |format| send_image(processed_image, format) }
    end

    def zoom
      image_file = @picture.image_file
      respond_to { |format| send_image(image_file, format) }
    end

    private

    def ensure_secure_params
      token = params[:sh]
      digest = PictureAttributes.secure(params)
      bad_request unless token && (token == digest)
    end

    def bad_request
      render text: "Bad picture parameters in #{request.path}", status: 400
      return false
    end

    def send_image(image, format)
      ALLOWED_IMAGE_TYPES.each do |type|
        format.send(type) do
          if type == 'jpeg'
            quality = params[:quality] || Config.get(:output_image_jpg_quality)
            image = image.encode(type, "-quality #{quality}")
          else
            image = image.encode(type)
          end
          render text: image.data
        end
      end
    end

    # Return the processed image dependent of size and cropping parameters
    def processed_image
      @image = @picture.image_file
      if @image.nil?
        raise MissingImageFileError, "Missing image file for #{@picture.inspect}"
      end
      if params[:crop_size].present? && params[:crop_from].present?
        @image = @image.thumb crop_geometry_string(params)
        @image.thumb(resize_geometry_string)
      elsif params[:crop] == 'crop' && @size.present?
        @image.thumb(geometry_string)
      elsif @size.present?
        @image.thumb(resize_geometry_string)
      else
        @image
      end
    end

    # Returns the Imagemagick geometry string for cropping the image.
    def crop_geometry_string(params)
      crop_from_x, crop_from_y = params[:crop_from].split('x')
      "#{params[:crop_size]}+#{crop_from_x}+#{crop_from_y}"
    end

    # Returns the Imagemagick geometry string used to resize the image.
    def resize_geometry_string
      params[:upsample] == 'true' ? @size.to_s : "#{@size}>"
    end

    # Returns the Imagemagick geometry string with normalized width and height values
    #
    # Prevents upscaling unless :upsample param is true,
    # because unfurtunally Dragonfly does not handle this correctly while cropping
    #
    def geometry_string
      return @size if params[:upsample] == 'true'
      sizes_to_geometry_string *normalized_sizes(*@size.split('x'))
    end

    # Ensures that the size is never greater than original image size
    def normalized_sizes(width, height)
      if width.to_i > @image.width
        width = @image.width
      end
      if height.to_i > @image.height
        height = @image.height
      end
      return width, height
    end

    # Returns the geometry string for given sizes.
    def sizes_to_geometry_string(width, height)
      if height.blank? && width.present?
        width.to_s
      else
        "#{width}x#{height}c" # This is really only used for cropping; the c at the end indicates crop from "Center"
      end
    end

  end
end
