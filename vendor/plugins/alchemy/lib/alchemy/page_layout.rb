class Alchemy::PageLayout
  
  def self.molecule_names_for(page_layout)
    page_layouts = self.get_layouts
    layout_description = page_layouts.select{ |p| p["name"].downcase == page_layout.downcase }
    raise "No Layout Description for #{page_layout} found! in page_layouts.yml" if layout_description.blank?
    layout_description.first["molecules"]
  end

  def self.get_layouts
    if File.exists? "#{RAILS_ROOT}/config/alchemy/page_layouts.yml"
      layouts = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/page_layouts.yml" )
    elsif File.exists? "#{RAILS_ROOT}/config/alchemy/page_layouts.yml"
      layouts = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/page_layouts.yml" )
    else
      raise "Could not read page_layouts.yml"
    end
    layouts
  end

  def self.get(name = "")
    self.get_layouts.detect{|a| a["name"].downcase == name.downcase}
  end

  def self.get_layouts_for_select(language, options = {})
    array = []
    if options[:newsletter]
      self.get_layouts.each do |layout|
        if layout["newsletter"] == true
          array << [layout["display_name"], layout["name"]]
        end
      end
    else
      self.get_layouts.each do |layout|
        used = layout["unique"] && self.has_another_page_this_layout?(layout["name"], language)
        if !(layout["hide"] == true) && !used && !(layout["newsletter"] == true)
          display_name = (layout["display_name"].blank? ? layout["name"].camelize : layout["display_name"])
          array << [display_name, layout["name"]]
        end
      end
    end
    array
  end
  
  def self.get_page_layout_names
    a = []
    self.get_layouts.each{ |l| a << l.keys.first}
    a
  end
  
  def self.has_another_page_this_layout?( layout, language)
    !Page.find(:all, :conditions => {:page_layout => layout, :language => language}).blank?
  end
  
end
