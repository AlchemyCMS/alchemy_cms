module Admin::ImagesHelper
  
  def create_or_assign_url(image_to_assign, options, swap)
    if @content.nil?
      {
        :controller => :contents,
        :action => :create,
        :image_id => image_to_assign.id,
        :content => {
          :essence_type => "EssencePicture",
          :element_id => @element.id
        },
        :options => options
      }
    else
      {
        :controller => :essence_pictures,
        :action => :assign,
        :image_id => image_to_assign.id,
        :id => @content.id,
        :options => options
      }
    end
  end
  
end
