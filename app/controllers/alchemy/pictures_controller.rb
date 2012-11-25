module Alchemy
  class PicturesController < Alchemy::BaseController

    ALLOWED_IMAGE_TYPES = %w(png jpeg gif)

    caches_page :show, :thumbnail, :zoom

    before_filter :load_picture, :ensure_secure_params

    filter_access_to :show, :attribute_check => true, :model => Alchemy::Picture, :load_method => :load_picture
    filter_access_to :thumbnail

    def show
      image_file = @picture.image_file

      upsample = params[:upsample] == 'true'
      crop_from = normalized_size(params[:crop_from])
      crop_size = params[:crop_size]
      size = params[:size]

      if params[:crop_size].present? && params[:crop_from].present?
        crop_from = params[:crop_from].split('x')
        image_file = image_file.process(:thumb, "#{params[:crop_size]}+#{crop_from[0]}+#{crop_from[1]}")
      elsif params[:crop] == 'crop' && size.present?
        image_file = image_file.process(:thumb, "#{size}#")
      end

      if size.present?
        image_file = image_file.process(:resize, size + '>')
      end

      respond_to { |format| send_image(image_file, format) }
    end

    def thumbnail
      image_file = @picture.image_file

      case params[:size]
        when "small" then size = "80x60"
        when "medium" then size = "160x120"
        when "large" then size = "240x180"
        when nil then size = "111x93"
      else
        size = params[:size]
      end

      if params[:crop_size].present? && params[:crop_from].present?
        crop_from = params[:crop_from].split('x')
        image_file = image_file.process(:thumb, "#{params[:crop_size]}+#{crop_from[0]}+#{crop_from[1]}")
      elsif params[:crop] == 'crop' && size.present?
        image_file = image_file.process(:thumb, "#{size}#")
      end

      if size.present?
        image_file = image_file.process(:resize, size + '>')
      end

      respond_to { |format| send_image(image_file, format) }
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
      digest = Digest::SHA1.hexdigest(secured_params)[0..15]
      bad_request unless token && (token == digest)
    end

    def secured_params
      [params[:id], params[:size], params[:crop], params[:crop_from], params[:crop_size], params[:quality], Rails.configuration.secret_token].join('-')
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

  end
end
