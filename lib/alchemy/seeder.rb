module Alchemy
  class Seeder
    
    # This seed builds the necessary page structure for alchemy in your db.
    # Put Alchemy::Seeder.seed! inside your db/seeds.rb file and run it with rake db:seed.
    def self.seed!
      errors = []
      notices = []

      lang = Language.find_or_initialize_by_code(
        :name => 'Deutsch',
        :code => 'de',
        :frontpage_name => 'Startseite',
        :page_layout => 'intro',
        :public => true,
        :default => true
      )
      if lang.new_record?
        if lang.save
          puts "== Created language #{lang.name}"
        else
          errors << "Errors creating language #{lang.name}: #{lang.errors.full_messages}"
        end
      else
        notices << "Language #{lang.name} already present"
      end

      root = Page.find_or_initialize_by_name(
        :name => 'Root',
        :do_not_autogenerate => true,
        :do_not_sweep => true,
        :language => lang
      )
      if root.new_record?
        if root.save
          # We have to remove the language, because active record validates its presence on create.
          root.language = nil
          root.save
          puts "== Created page #{root.name}"
        else
          errors << "Errors creating page #{root.name}: #{root.errors.full_messages}"
        end
      else
        notices << "Page #{root.name} already present"
      end

      index = Page.find_or_initialize_by_name(
        :name => lang.frontpage_name,
        :page_layout => lang.page_layout,
        :language => lang,
        :language_root => true
      )
      if index.new_record?
        if index.save
          puts "== Created page #{index.name}"
        else
          errors << "Errors creating page #{index.name}: #{index.errors.full_messages}"
        end
      else
        notices << "Page #{index.name} already present"
      end
      
      layoutroot = Page.find_or_initialize_by_name(
        :name => 'LayoutRoot',
        :do_not_autogenerate => true,
        :do_not_sweep => true,
        :layoutpage => true,
        :language => lang
      )
      if layoutroot.new_record?
        if layoutroot.save
          puts "== Created Page #{layoutroot.name}"
        else
          errors << "Errors creating page #{layoutroot.name}: #{layoutroot.errors.full_messages}"
        end
      else
        notices << "Page #{layoutroot.name} already present"
      end
      
      if errors.blank?
        index.move_to_child_of root
        layoutroot.move_to_child_of root
      else
        puts "WARNING! Some pages could not be created:"
        errors.map{ |error| puts error }
      end
      puts "Success!"
      notices.map{ |note| puts note }
    end
    
    # This method is for running after an upgrade of Alchemy if you already seeded the db once.
    # Put Alchemy::Seeder.upgrade! inside your db/seeds.rb file and run it with rake db:seed.
    def self.upgrade!
      lang = Language.find_or_initialize_by_code(
        :name => 'Deutsch',
        :code => 'de',
        :frontpage_name => 'Startseite',
        :page_layout => 'intro',
        :public => true
      )
      lang.default = true
      lang.save
      ActiveRecord::Base.connection.execute("UPDATE pages SET language_root = 1 WHERE language_root IS NOT NULL")
      Page.all.each do |page|
        unless page.language_code.blank?
          root = page.get_language_root
          lang = Language.find_or_create_by_code(
            :name => page.language_code.capitalize,
            :code => page.language_code,
            :frontpage_name => root.name,
            :page_layout => root.page_layout,
            :public => true
          )
          page.language = lang
          page.save(false)
        end
      end
      Page.layoutpages.each do |page|
        if page.language.class == String || page.language.nil?
          page.language = lang
          page.language_code = page.language.code
          page.save(false)
        end
      end
    end
    
  end
end
