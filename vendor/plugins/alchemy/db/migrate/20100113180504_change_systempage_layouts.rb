class ChangeSystempageLayouts < ActiveRecord::Migration
  def self.up
    WaPage.reset_column_information
    
    header = WaPage.find_by_urlname("system_header")
    if header
      header.page_layout = "system_header"
      header.save
    end
    
    footer = WaPage.find_by_urlname("system_footer")
    if footer
      footer.page_layout = "system_footer"
      footer.save
    end    
  end

  def self.down
    header = WaPage.find_by_urlname("system_header")
    if header
      header.page_layout = "systempage"
      header.save
    end
    
    footer = WaPage.find_by_urlname("system_footer")
    if footer
      footer.page_layout = "systempage"
      footer.save
    end
  end
end
