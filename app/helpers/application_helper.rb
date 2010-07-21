# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def header_image
    begin
      url_for(
        :controller => :pictures,
        :action => :show,
        :id => current_page.elements.find_by_name("header").content_by_type('EssencePicture').essence.picture.id,
        :size => "1200x1200",
        :format => :jpg
      )
    rescue
      ""
    end
  end
  
  def language_switches
    links = []
    Page.find(:all, :conditions => "language_root_for IS NOT NULL AND public=1").each do |page|
      links << link_to(page.language.upcase, show_page_with_language_url(:urlname => page.urlname, :lang => page.language), :class => (session[:language] == page.language ? 'active' : nil))
    end
    links.join("<span class='seperator'></span>")
  end
  
end
