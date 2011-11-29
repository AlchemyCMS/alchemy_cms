require 'yaml'

module Alchemy
	class Seeder

		# This seed builds the necessary page structure for alchemy in your db.
		# Put Alchemy::Seeder.seed! inside your db/seeds.rb file and run it with rake db:seed.
		def self.seed!
			errors = []
			notices = []
			
			default_language = Alchemy::Config.get(:default_language)
			
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
			
			if errors.blank?
				puts "Success!"
				notices.map{ |note| puts note }
			else
				puts "WARNING! Some pages could not be created:"
				errors.map{ |error| puts error }
			end
		end

	end
end
