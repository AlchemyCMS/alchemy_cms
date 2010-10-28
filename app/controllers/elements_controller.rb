class ElementsController < AlchemyController
  
  filter_access_to [:show], :attribute_check => true
  
  def show
    @element = Element.find(params[:id])
    @page = @element.page
    @container_id = params[:container_id]
    render :layout => false
  end
  
end