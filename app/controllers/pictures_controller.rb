class PicturesController < AlchemyController
  
  caches_page :show, :thumbnail, :zoom
  
  filter_access_to :zoom, :thumbnail
  
  def show
    @picture = Picture.find(params[:id])
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
    @crop = !params[:crop_size].blank? && !params[:crop_from].blank?
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

private

  def normalized_size(size)
    return "" if size.blank?
    size.split("x").map do |s| 
      s.to_i < 0 ? 0 : s.to_i
    end.join('x')
  end

end
