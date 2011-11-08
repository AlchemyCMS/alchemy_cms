module Alchemy
  class PageLayout
    
    def self.element_names_for(page_layout)
      layout_description = get(page_layout)
      if layout_description.blank?
        puts "\n+++ Warning: No Layout Description for #{page_layout} found! in page_layouts.yml\n"
        return []
      else
        layout_description["elements"]
      end
    end
    
    # Returns the page_layout.yml file. Tries to first load from config/alchemy and if not found from vendor/plugins/alchemy/config/alchemy.
    def self.get_layouts
			if File.exists? "#{Rails.root}/config/alchemy/page_layouts.yml"
				layouts = YAML.load_file( "#{Rails.root}/config/alchemy/page_layouts.yml" )
			end
			if !layouts
				if File.exists?(File.join(File.dirname(__FILE__), "../../config/alchemy/page_layouts.yml"))
					layouts = YAML.load_file( File.join(File.dirname(__FILE__), "../../config/alchemy/page_layouts.yml") )
				end
			end
			if !layouts
				raise LoadError, "Could not find page_layouts.yml file! Please run: rails generate alchemy:scaffold"
			end
			layouts
    end
   
    # Returns the page_layout description found by name in page_layouts.yml
    def self.get(name = "")
      self.get_layouts.detect{ |a| a["name"].downcase == name.downcase }
    end
    
    # Returns page layouts ready for Rails' select form helper.
    def self.get_layouts_for_select(language_id, layoutpage = false)
      layouts_for_select = [ [ _("Please choose"), "" ] ]
      self.selectable_layouts(language_id, layoutpage).each do |layout|
        display_name = I18n.t("alchemy.page_layout_names.#{layout['name']}", :default => layout['name'].camelize)
        layouts_for_select << [display_name, layout["name"]]
      end
      layouts_for_select
    end
    
    def self.selectable_layouts(language_id, layoutpage = false)
      self.get_layouts.select do |layout|
        used = layout["unique"] && self.has_another_page_this_layout?(layout["name"], language_id)
        if layoutpage
          layout["layoutpage"] == true && !used && layout["newsletter"] != true
        else
          layout["layoutpage"] != true && !used && layout["newsletter"] != true
        end
      end
    end
    
    def self.get_page_layout_names
      a = []
      self.get_layouts.each{ |l| a << l.keys.first }
      a
    end
    
    def self.has_another_page_this_layout?(layout, language_id)
      Page.where({:page_layout => layout, :language_id => language_id}).any?
    end
    
  end
end
