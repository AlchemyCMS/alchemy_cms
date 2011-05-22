xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @page.title
    xml.description @page.meta_description
    if multi_language?
      xml.link show_page_with_language_url(:urlname => @page.urlname, :lang => session[:language_id])
    else
      xml.link show_page_url(:urlname => @page.urlname)
    end
    
    for element in @page.elements.find_all_by_name('news')
      xml.item do
        xml.title render_essence_view_by_name(element, 'headline')
        xml.description render_essence_view_by_name(element, 'text')
        xml.pubDate render_essence_view_by_name(element, 'date', :date_format => :rfc822)
        if multi_language?
          xml.link show_page_with_language_url(:urlname => element.page.urlname, :anchor => element_dom_id(element), :lang => session[:language_id])
          xml.guid show_page_with_language_url(:urlname => element.page.urlname, :anchor => element_dom_id(element), :lang => session[:language_id])
        else
          xml.link show_page_url(:urlname => element.page.urlname, :anchor => element_dom_id(element))
          xml.guid show_page_url(:urlname => element.page.urlname, :anchor => element_dom_id(element))
        end
      end
    end
  end
end
