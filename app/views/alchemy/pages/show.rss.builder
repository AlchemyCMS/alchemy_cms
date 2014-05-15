xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do

  xml.channel do

    xml.title @page.title
    xml.description @page.meta_description
    xml.link show_page_url(:urlname => @page.urlname, :lang => multi_language? ? @page.language_code : nil)

    @page.feed_elements.each do |element|
      xml.item do
        xml.title element.content_for_rss_title.try(:ingredient)
        xml.description element.content_for_rss_description.try(:ingredient)
        xml.pubDate element.ingredient('date').to_s(:rfc822) if element.has_ingredient?('date')
        xml.link show_page_url(:urlname => @page.urlname, :anchor => element_dom_id(element), :lang => multi_language? ? @page.language_code : nil)
        xml.guid show_page_url(:urlname => @page.urlname, :anchor => element_dom_id(element), :lang => multi_language? ? @page.language_code : nil)
      end
    end

  end

end
