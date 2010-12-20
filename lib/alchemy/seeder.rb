module Alchemy
  class Seeder
    
    def self.seed!
      errors = []
      lang = Language.find_or_initialize_by_code(
        :name => 'Deutsch',
        :code => 'de',
        :frontpage_name => 'Startseite',
        :page_layout => 'intro',
        :public => true,
        :default => true
      )
      if lang.new_record? && lang.save
        puts "== Created Language #{lang.name}"
        root = Page.find_or_initialize_by_name(
          :name => 'Root',
          :do_not_autogenerate => true,
          :do_not_sweep => true,
          :language => lang
        )
        if root.new_record? && root.save
          puts "== Created Page #{root.name}"
          # We have to remove the language, because active record validates its presence on create.
          root.language = nil
          root.save
        else
          errors << "Root page could not be created"
        end
        index = Page.find_or_initialize_by_name(
          :name => lang.frontpage_name,
          :page_layout => lang.page_layout,
          :public => false,
          :visible => true,
          :language => lang,
          :language_root => true
        )
        if index.new_record? && index.save
          puts "== Created Page #{index.name}"
        else
          errors << "Index page could not be created"
        end
        layoutroot = Page.find_or_initialize_by_name(
          :name => 'LayoutRoot',
          :do_not_autogenerate => true,
          :do_not_sweep => true,
          :layoutpage => true,
          :language => lang
        )
        if layoutroot.new_record? && layoutroot.save
          puts "== Created Page #{layoutroot.name}"
        else
          errors << "Layoutroot page could not be created"
        end
        header = Page.find_or_initialize_by_name(
          :name => 'Layout Header',
          :page_layout => 'layout_header',
          :layoutpage => true,
          :language => lang
        )
        if header.new_record? && header.save
          puts "== Created Page #{header.name}"
        else
          errors << "Header layoutpage could not be created"
        end
        footer = Page.find_or_initialize_by_name(
          :name => 'Layout Footer',
          :page_layout => 'layout_footer',
          :layoutpage => true,
          :language => lang
        )
        if footer.new_record? && footer.save
          puts "== Created Page #{footer.name}"
        else
          errors << "Footer layoutpage could not be created"
        end        
        if errors.blank?
          index.move_to_child_of root
          layoutroot.move_to_child_of root
          header.move_to_child_of layoutroot
          footer.move_to_child_of layoutroot
        else
          puts "== Aborting! Some pages could not be created:\n#{errors.join('\n')}"
          raise
        end
      else
        raise "== Aborting! Creating language failed!"
      end
    end
    
  end
end
