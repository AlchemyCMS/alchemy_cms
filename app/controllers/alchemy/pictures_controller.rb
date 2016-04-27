module Alchemy
  class PicturesController < Alchemy::BaseController
    ALLOWED_IMAGE_TYPES = %w(png jpeg gif svg)

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

      respond_to { |format| send_image(processed_image, format, flatten: true) }
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

    def send_image(image, format, opts = {})
      request.session_options[:skip] = true
      ALLOWED_IMAGE_TYPES.each do |type|
        # Flatten animated gifs, only if converting to a different format.
        # Can be overwritten via +options[:flatten]+.
        options = {
          flatten: type != "gif" && image.ext == 'gif'
        }.merge(opts)

        format.send(type) do
          encoding_options = []
          if type == 'jpeg'
            quality = params[:quality] || Config.get(:output_image_jpg_quality)
            encoding_options << "-quality #{quality}"
          end
          if options[:flatten]
            encoding_options << "-flatten"
          end
          if @picture.has_convertible_format?
            render text: image.encode(type, encoding_options.join(' ')).data
          else
            render text: image.data
          end
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
      if resizable?
        if params[:crop_size].present? && params[:crop_from].present? || params[:crop].present?
          @picture.crop(@size, params[:crop_from], params[:crop_size], @upsample)
        else
          @picture.resize(@size, @upsample)
        end
      else
        @image
      end
    end

    def resizable?
      @size.present? && @picture.has_convertible_format?
    end
  end
end
