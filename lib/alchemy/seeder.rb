module Alchemy
  class Seeder
    
    # This seed builds the necessary page structure for alchemy in your db.
    # Put Alchemy::Seeder.seed! inside your db/seeds.rb file and run it with rake db:seed.
    def self.seed!
      FastGettext.add_text_domain 'alchemy', :path => File.join(Rails.root, 'vendor/plugins/alchemy/locale')
      FastGettext.text_domain = 'alchemy'
      FastGettext.available_locales = ['de', 'en']
      FastGettext.locale = Alchemy::Configuration.get(:default_translation)
      
      errors = []
      notices = []
      
      default_language = Alchemy::Configuration.get(:default_language)
      
      lang = Language.find_or_initialize_by_code(
        :name => default_language['name'],
        :code => default_language['code'],
        :frontpage_name => default_language['frontpage_name'],
        :page_layout => default_language['page_layout'],
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
        notices << "== Skipping! Language #{lang.name} was already present"
      end
      
      root = Page.find_or_initialize_by_name(
        :name => 'Root',
        :page_layout => "rootpage",
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
        notices << "== Skipping! Page #{root.name} was already present"
      end
      
      index = Page.find_or_initialize_by_name(
        :name => lang.frontpage_name,
        :page_layout => lang.page_layout,
        :language => lang,
        :language_root => true,
        :do_not_autogenerate => true,
        :do_not_sweep => true
      )
      if index.new_record?
        if index.save
          puts "== Created page #{index.name}"
        else
          errors << "Errors creating page #{index.name}: #{index.errors.full_messages}"
        end
      else
        notices << "== Skipping! Page #{index.name} was already present"
      end
      
      if errors.blank?
        index.move_to_child_of root
      else
        puts "WARNING! Some pages could not be created:"
        errors.map{ |error| puts error }
      end
      puts "Success!"
      notices.map{ |note| puts note }
    end
    
    # This method is for running after upgrading an old Alchemy version without Language Model (pre v1.5).
    # Put Alchemy::Seeder.upgrade! inside your db/seeds.rb file and run it with rake db:seed.
    def self.upgrade!
      seed!
      Page.all.each do |page|
        if !page.language_code.blank? && page.language.nil?
          root = page.get_language_root
          lang = Language.find_or_create_by_code(
            :name => page.language_code.capitalize,
            :code => page.language_code,
            :frontpage_name => root.name,
            :page_layout => root.page_layout,
            :public => true
          )
          page.language = lang
          if page.save(false)
            puts "== Set language for page #{page.name} to #{lang.name}"
          end
        else
          puts "== Skipping! Language for page #{page.name} already set."
        end
      end
      default_language = Language.get_default
      Page.layoutpages.each do |page|
        if page.language.class == String || page.language.nil?
          page.language = default_language
          if page.save(false)
            puts "== Set language for page #{page.name} to #{default_language.name}"
          end
        else
          puts "== Skipping! Language for page #{page.name} already set."
        end
      end
    end
    
  end
end
