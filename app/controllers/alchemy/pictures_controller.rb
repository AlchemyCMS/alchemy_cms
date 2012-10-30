module Alchemy
  class PicturesController < Alchemy::BaseController

    caches_page :show, :thumbnail, :zoom

    before_filter :load_picture, :ensure_secure_params

    filter_access_to :show, :attribute_check => true, :model => Alchemy::Picture, :load_method => :load_picture
    filter_access_to :thumbnail

    def show
      @size = params[:size]
      @crop = !params[:crop].nil?
      @crop_from = normalized_size(params[:crop_from])
      @crop_size = params[:crop_size]
      @padding = params[:padding]
      @upsample = !params[:upsample].nil? ? true : false
      @effects = params[:effects]
      respond_to do |format|
        format.jpg
        format.png
        format.gif
      end
    end

    def thumbnail
      case params[:size]
      when "small"
        @size = "80x60"
      when "medium"
        @size = "160x120"
      when "large"
        @size = "240x180"
      when nil
        @size = "111x93"
      else
        @size = params[:size]
      end
      if !params[:crop_size].blank? && !params[:crop_from].blank?
        @crop = true
      elsif params[:crop] == 'crop'
        @default_crop = true
      end
    end

    def zoom
      #
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
      [params[:id], params[:size], params[:crop], params[:crop_from], params[:crop_size], Rails.configuration.secret_token].join('-')
    end

    def bad_request
      render :text => "Bad picture parameters in #{request.path}", :status => 400
      return false
    end

  end
end
