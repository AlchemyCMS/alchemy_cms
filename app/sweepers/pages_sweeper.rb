class PagesSweeper < ActionController::Caching::Sweeper
  
  observe Page
  
  def after_update(page)
    unless page.layoutpage?
      expire_page(page)
      check_multipage_elements(page)
    end
  end
  
  def after_destroy(page)
    unless page.layoutpage?
      expire_page(page)
      check_multipage_elements(page)
    end
  end
  
private
  
  def check_multipage_elements(page)
    page.elements.each do |element|
      # are their pages beneath mine?
      if !element.to_be_sweeped_pages.detect{ |p| p != page }.nil?
        # yepp! there are more pages then mine
        pages = element.to_be_sweeped_pages.find_all_by_public_and_locked(true, false)
        if !pages.blank?
          # expire current page, even if it's locked
          pages.push(page).each do |page|
            expire_page(page)
          end
        end
      end
    end
  end
  
  def expire_page(page)
    if Alchemy::Controller.multi_language?
      expire_action("#{page.language.code}/#{page.urlname_was}") unless page.do_not_sweep
    else
      expire_action("#{page.urlname_was}") unless page.do_not_sweep
    end
    #backend sitemap caches
    # unless page.do_not_sweep || page.nil? || current_user.nil?
    #   expire_fragment("page_#{page.id}_for_user_#{current_user.id}_lines")
    #   expire_fragment("page_#{page.id}_for_user_#{current_user.id}_status")
    #   expire_fragment("page_#{page.id}_for_user_#{current_user.id}_tools")
    # end
  end
  
end
