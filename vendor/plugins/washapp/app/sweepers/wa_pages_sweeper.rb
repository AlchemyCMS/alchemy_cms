class WaPagesSweeper < ActionController::Caching::Sweeper
  
  observe WaPage
  
  def after_update(page)
    expire_wa_page(page)
    check_multipage_molecules(page)
  end
  
  def after_destroy(page)
    expire_wa_page(page)
    check_multipage_molecules(page)
  end
  
private
  
  def check_multipage_molecules(page)
    page.wa_molecules.each do |molecule|
      # are their pages beneath mine?
      if !molecule.to_be_sweeped_pages.detect{ |p| p != page }.nil?
        # yepp! there are more pages then mine
        pages = molecule.to_be_sweeped_pages.find_all_by_public_and_locked(true, false)
        if !pages.blank?
          # expire current page, even if it's locked
          pages.push(page).each do |page|
            expire_wa_page(page)
          end
        end
      end
    end
  end
  
  def expire_wa_page(page)
    if Washapp::Controller.multi_language?
      expire_action("#{page.language}/#{page.urlname_was}") unless page.do_not_sweep
    else
      expire_action("#{page.urlname_was}") unless page.do_not_sweep
    end
    #backend sitemap caches
    unless page.do_not_sweep || page.nil? || current_user.nil?
      expire_fragment("page_#{page.id}_for_user_#{current_user.id}_lines")
      expire_fragment("page_#{page.id}_for_user_#{current_user.id}_status")
      expire_fragment("page_#{page.id}_for_user_#{current_user.id}_tools")
    end
  end
  
end
