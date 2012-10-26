module Alchemy
  class PageLayout
    class << self

      def element_names_for(page_layout)
        layout_description = get(page_layout)
        if layout_description.blank?
          puts "\n+++ Warning: No Layout Description for #{page_layout} found! in page_layouts.yml\n"
          return []
        else
          layout_description["elements"]
        end
      end

      # Returns all layouts defined in +config/alchemy/page_layout.yml+.
      def all
        @@definitions ||= read_layouts_file
      end

      # Add additional pagelayout definitions. I.E. from your module.
      # Call +Alchemy::PageLayout.add(your_layout_definition)+ in your engine.rb file.
      # You can pass a single layout definition as Hash, or a collection of pagelayouts as Array.
      # Example Pagelayout definitions can be found in the +page_layouts.yml+ from the standard set.
      def add(page_layout)
        all
        if page_layout.is_a?(Array)
          @@definitions += page_layout
        elsif page_layout.is_a?(Hash)
          @@definitions << page_layout
        else
          raise TypeError
        end
      end

      # Returns the page_layout description found by name in page_layouts.yml
      def get(name)
        return {} if name.blank?
        all.detect { |a| a["name"].downcase == name.downcase }
      end

      def get_all_by_attributes(attributes)
        return [] if attributes.blank?
        if attributes.class.name == 'Hash'
          layouts = []
          attributes.stringify_keys.each do |key, value|
            result = all.select { |a| a[key].to_s.downcase == value.to_s.downcase if a.has_key?(key) }
            layouts += result unless result.empty?
          end
          return layouts
        else
          return []
        end
      end

      # Returns page layouts ready for Rails' select form helper.
      def layouts_for_select(language_id, layoutpage = false)
        map_layouts(selectable_layouts(language_id, layoutpage), [[I18n.t("Please choose"), ""]])
      end

      def layouts_with_own_for_select(own_layout, language_id, layoutpage)
        layouts = selectable_layouts(language_id, layoutpage)
        if layouts.detect { |l| l['name'] == own_layout } == nil
          map_array = [[I18n.t(own_layout, :scope => 'page_layout_names'), own_layout]]
        else
          map_array = []
        end
        map_layouts(layouts, map_array)
      end

      # Maps given layouts for Rails select form helper.
      def map_layouts(layouts, map_array = [])
        layouts.each do |layout|
          map_array << [
            I18n.t(layout['name'], :scope => 'page_layout_names'),
            layout["name"]
          ]
        end
        map_array
      end

      def selectable_layouts(language_id, layoutpage = false)
        all.select do |layout|
          next if layout["hide"]
          used = layout["unique"] && has_a_page_this_layout?(layout["name"], language_id)
          if layoutpage
            layout["layoutpage"] == true && !used
          else
            layout["layoutpage"] != true && !used
          end
        end
      end

      def has_a_page_this_layout?(layout, language_id)
        Page.where({:page_layout => layout, :language_id => language_id}).any?
      end

    private

      # Reads the layout definitions from +config/alchemy/page_layouts.yml+.
      def read_layouts_file
        if File.exists? "#{Rails.root}/config/alchemy/page_layouts.yml"
          layouts = YAML.load_file "#{Rails.root}/config/alchemy/page_layouts.yml"
        else
          raise LoadError, "Could not find page_layouts.yml file! Please run: rails generate alchemy:scaffold"
        end
        # Since YAML returns false for an empty file, we have to normalize it here.
        layouts || []
      end

    end
  end
end
