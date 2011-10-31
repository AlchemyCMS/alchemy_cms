class Admin::TrashController < AlchemyController
  
  filter_access_to [:index, :clear]
  
  before_filter :set_translation
  
  helper Admin::ElementsHelper
  
  def index
    @elements = Element.trashed
    @page = Page.find_by_id(params[:page_id])
    @allowed_elements = Element.all_for_page(@page)
    render :layout => false
  rescue Exception => e
    exception_handler(e)
  end
  
  def clear
    @page = Page.find_by_id(params[:page_id])
    @elements = Element.trashed
    @elements.map(&:destroy)
    render :update do |page|
      page.call('Alchemy.growl', _("Cleared trash"))
      page << "Alchemy.refreshTrashWindow(#{@page.id})"
      page << "jQuery('#element_trash_button .icon').removeClass('full')"
    end
  rescue Exception => e
    exception_handler(e)
  end
  
end
