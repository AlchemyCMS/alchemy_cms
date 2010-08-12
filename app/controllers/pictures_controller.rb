class PicturesController < ApplicationController
  
  caches_page :show, :thumbnail, :zoom
  
  filter_access_to :zoom, :thumbnail
  
  def show
    @picture = Picture.find(params[:id])
    @size = params[:size]
    @crop = !params[:crop].nil?
    @crop_from = params[:crop_from]
    @crop_size = params[:crop_size]
    @padding = params[:padding]
    @upsample = !params[:upsample].nil? ? true : false
    @options = params[:options]
    respond_to do |format|
      format.jpg
      format.png
      format.gif
    end
  end
  
  def thumbnail
    @picture = Picture.find(params[:id])
    case params[:size]
    when "small"
      then
      @size = "80x60"
    when "medium"
      then
      @size = "160x120"
    when "large"
      then
      @size = "240x180"
    else
      @size = "111x93"
    end
    @crop = true
    respond_to do |format|
      format.png
    end
  end
  
  def zoom
    @picture = Picture.find(params[:id])
    respond_to do |format|
      format.png
    end
  end
  
end
