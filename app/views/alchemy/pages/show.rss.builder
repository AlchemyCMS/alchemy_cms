xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title @page.title
    xml.description @page.meta_description
    xml.link show_alchemy_page_url(@page)

    @page.feed_elements.each do |element|
      xml.item do
        xml.title element.content_for_rss_title.try(:ingredient)
        xml.description element.content_for_rss_description.try(:ingredient)
        if element.has_ingredient?('date')
          xml.pubDate element.ingredient('date').to_s(:rfc822)
        end
        xml.link show_alchemy_page_url(@page, anchor: element_dom_id(element))
        xml.guid show_alchemy_page_url(@page, anchor: element_dom_id(element))
      end
    end
  end
end
