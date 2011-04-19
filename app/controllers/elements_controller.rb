class ElementsController < AlchemyController
  
  filter_access_to [:show], :attribute_check => true
  layout false
  
  # Returns the element partial as HTML or as JavaScript that tries to replace a given +container_id+ with the partial content via jQuery.
  def show
    @element = Element.find(params[:id])
    @page = @element.page
    respond_to do |format|
      format.html
      format.js
    end
  end
  
end