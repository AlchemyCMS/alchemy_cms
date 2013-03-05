module Alchemy
  class PicturesController < Alchemy::BaseController

    ALLOWED_IMAGE_TYPES = %w(png jpeg gif)

    caches_page :show, :thumbnail, :zoom

    before_filter :load_picture, :ensure_secure_params

    filter_access_to :show, :attribute_check => true, :model => Alchemy::Picture, :load_method => :load_picture
    filter_access_to :thumbnail

    def show
      @size = params[:size]

      expires_in 1.month, public: !@picture.restricted?
      respond_to { |format| send_image(processed_image, format) }
    end

    def thumbnail
      case params[:size]
        when "small" then @size = "80x60"
        when "medium" then @size = "160x120"
        when "large" then @size = "240x180"
        when nil then @size = "111x93"
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

    def normalized_size(size)
      return "" if size.blank?
      size.split("x").map do |s|
        s.to_i < 0 ? 0 : s.to_i
      end.join('x')
    end

    def load_picture
      @picture ||= Picture.find(params[:id])
    end

    def ensure_secure_params
      token = params[:sh]
      digest = PictureAttributes.secure(params)
      bad_request unless token && (token == digest)
    end

    def bad_request
      render :text => "Bad picture parameters in #{request.path}", :status => 400
      return false
    end

    def send_image(image_file, format)
      ALLOWED_IMAGE_TYPES.each do |type|
        format.send(type) do
          if type == "jpeg"
            quality = params[:quality] || Config.get(:output_image_jpg_quality)
            image_file = image_file.encode(type, "-quality #{quality}")
          else
            image_file = image_file.encode(type)
          end
          render :text => image_file.data
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
        crop_from = params[:crop_from].split('x')
        image_file = image_file.process(:thumb, "#{params[:crop_size]}+#{crop_from[0]}+#{crop_from[1]}")
        image_file.process(:resize, @size + '>')
      elsif params[:crop] == 'crop' && @size.present?
        width, height = @size.split('x').collect(&:to_i)
        # prevent upscaling unless :upsample param is true
        # unfurtunally dragonfly does not handle this correctly while cropping
        unless params[:upsample] == 'true'
          if width > image_file.width
            width = image_file.width
          end
          if height > image_file.height
            height = image_file.height
          end
        end
        image_file.process(:resize_and_crop, :width => width, :height => height, :gravity => '#')
      elsif @size.present?
        image_file.process(:resize, "#{@size}>")
      else
        image_file
      end
    end

  end
end
