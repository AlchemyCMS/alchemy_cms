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

    def send_image(image_file, format)
      ALLOWED_IMAGE_TYPES.each do |type|
        format.send(type) do
          if type == 'jpeg'
            quality = params[:quality] || Config.get(:output_image_jpg_quality)
            image_file = image_file.encode(type, "-quality #{quality}")
          else
            image_file = image_file.encode(type)
          end
          render text: image_file.data
        end
      end
    end

    # Return the processed image dependent of size and cropping parameters
    def processed_image
      image_file = @picture.image_file
      if image_file.nil?
        raise MissingImageFileError, "Missing image file for #{@picture.inspect}"
      end
      if params[:crop_size].present? && params[:crop_from].present?
        image_file = image_file.thumb crop_geometry_string(params)
        image_file.thumb(resize_geometry_string)
      elsif params[:crop] == 'crop' && @size.present?
        width, height = normalize_sizes(image_file)
        raise ArgumentError, "You have to state both width and height in the form 'widthxheight' when cropping" if width.nil? || height.nil?
        image_file.thumb("#{width}x#{height}#")
      elsif @size.present?
        image_file.thumb(resize_geometry_string)
      else
        image_file
      end
    end

    # Returns the Imagemagick geometry string for cropping the image.
    def crop_geometry_string(params)
      crop_from_x, crop_from_y = params[:crop_from].split('x')
      "#{params[:crop_size]}+#{crop_from_x}+#{crop_from_y}"
    end

    # Returns the Imagemagick geometry string used to resize the image.
    def resize_geometry_string
      @resize_geometry_string ||= begin
        params[:upsample] == 'true' ? @size.to_s : "#{@size}>"
      end
    end

    # Returns normalized width and height values
    #
    # Prevents upscaling unless :upsample param is true,
    # because unfurtunally Dragonfly does not handle this correctly while cropping
    #
    def normalize_sizes(image_file)
      width, height = @size.split('x').collect(&:to_i)
      return width, height if params[:upsample] == 'true'
      if width > image_file.width
        width = image_file.width
      end
      if height > image_file.height
        height = image_file.height
      end
      return width, height
    end

  end
end
