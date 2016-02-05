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
      respond_to { |format| send_image(@picture.image_file, format) }
    end

    private

    def ensure_secure_params
      token = params[:sh]
      digest = PictureAttributes.secure(params)
      bad_request unless token && (token == digest)
    end

    def bad_request
      render text: "Bad picture parameters in #{request.path}", status: 400
      false
    end

    def send_image(image, format)
      request.session_options[:skip] = true
      ALLOWED_IMAGE_TYPES.each do |type|
        format.send(type) do
          options = []
          if type == 'jpeg'
            quality = params[:quality] || Config.get(:output_image_jpg_quality)
            options << "-quality #{quality}"
          end
          # Flatten animated gifs, only if converting to a different format.
          options << "-flatten" if type != "gif" && image.ext == 'gif'
          render text: image.encode(type, options.join(' ')).data
        end
      end
    end

    # Return the processed image dependent of size and cropping parameters
    def processed_image
      @image = @picture.image_file
      @upsample = params[:upsample] == 'true' ? true : false
      if @image.nil?
        raise MissingImageFileError, "Missing image file for #{@picture.inspect}"
      end
      if @size.present?
        if params[:crop_size].present? && params[:crop_from].present? || params[:crop].present?
          @picture.crop(@size, params[:crop_from], params[:crop_size], @upsample)
        else
          @picture.resize(@size, @upsample)
        end
      else
        @image
      end
    end

  end
end
