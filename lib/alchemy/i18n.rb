module Alchemy
	class I18n

		def self.available_locales
			translation_files.collect { |f| f.match(/.{2}\.yml$/).to_s.gsub(/\.yml/, '') }.uniq
		end

		def self.translation_files
			Rails.application.config.i18n.load_path.select { |p| p.split('/').last.match(/alchemy/) }
		end

	end
end
