class PicturesController < ApplicationController
  
  caches_page :show
  
  def show
    @picture = Picture.find(params[:id])
    @size = params[:size]
    @crop = !params[:crop].nil?
    @padding = params[:padding]
    @upsample = !params[:upsample].nil? ? true : false
    @options = params[:options]
    respond_to do |format|
      format.jpg
      format.png
      format.gif
    end
  end
  
end
