namespace :alchemy do
	
	desc "Upgrades database to Alchemy CMS v#{Alchemy::VERSION}."
	task :upgrade => :environment do
		
		# invoke seed task
		Rake::Task['db:seed'].invoke
		
		# Creates Language model if it does not exist (Alchemy CMS prior v1.5)
		# Also creates missing associations between pages and languages
		Alchemy::Page.all.each do |page|
			if !page.language_code.blank? && page.language.nil?
				root = page.get_language_root
				lang = Alchemy::Language.find_or_create_by_code(
					:name => page.language_code.capitalize,
					:code => page.language_code,
					:frontpage_name => root.name,
					:page_layout => root.page_layout,
					:public => true
				)
				page.language = lang
				if page.save(:validate => false)
					puts "== Set language for page #{page.name} to #{lang.name}"
				end
			else
				puts "== Skipping! Language for page #{page.name} already set."
			end
		end
		default_language = Alchemy::Language.get_default
		Alchemy::Page.layoutpages.each do |page|
			if page.language.class == String || page.language.nil?
				page.language = default_language
				if page.save(:validate => false)
					puts "== Set language for page #{page.name} to #{default_language.name}"
				end
			else
				puts "== Skipping! Language for page #{page.name} already set."
			end
		end
		(Alchemy::EssencePicture.all + Alchemy::EssenceText.all).each do |essence|
			case essence.link_target
			when '1'
				if essence.update_attribute(:link_target, 'blank')
					puts "== Updated #{essence.preview_text} link target to #{essence.link_target}."
				end
			when '0'
				essence.update_attribute(:link_target, nil)
				puts "== Updated #{essence.preview_text} link target to #{essence.link_target.inspect}."
			end
		end

		# Updates all essence_type of Content if not already namespaced.
		depricated_contents = Alchemy::Content.where("essence_type LIKE ?", "Essence%")
		if depricated_contents.any?
			success = 0
			errors = []
			depricated_contents.each do |c|
				if c.update_attribute(:essence_type, c.essence_type.gsub(/^Essence/, 'Alchemy::Essence'))
					success += 1
				else
					errors << c.errors.full_messages
				end
			end
			puts "== Namespaced #{success} Essence-Types." if success > 0
			puts "!! #{errors.count} errors while namespacing Essence-Types.\n#{errors.join('\n')}" if errors > 0
		else
			puts "== Skipping! Already namespaced Essence-Types"
		end

	end

end