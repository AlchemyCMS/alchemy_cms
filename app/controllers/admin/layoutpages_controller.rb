class Admin::LayoutpagesController < AlchemyController
  
  filter_access_to :all
  
  def index
    @locked_pages = Page.all_locked_by(current_user)
    @layout_root = Page.find_or_create_layout_root_for(session[:language_id])
  end
  
end
