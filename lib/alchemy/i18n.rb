module Alchemy
	class I18n

		# A I18n Proxy for Alchemy translations
		# 
		# Instead of having to translate strings and defining a default value:
		# 
		#     Alchemy::I18n.t("Hello World!", :default => 'Hello World!')
		# 
		# We define this method to define the value only once:
		# 
		#     Alchemy::I18n.t("Hello World!")
		# 
		# Note that interpolation still works:
		# 
		#     Alchemy::I18n.t("Hello %{world}!", :world => @world)
		# 
		# === Notes
		# 
		# All translations are scoped into the +alchemy+ namespace.
		# Even scopes are scoped into the +alchemy+ namespace.
		# 
		# So a call for t('hello', :scope => :world) has to be translated like this:
		# 
		#   de:
		#     alchemy:
		#       world:
		#         hello: Hallo
		# 
		def self.t(msg, *args)
			options = args.extract_options!
			options[:default] = options[:default] ? options[:default] : msg
			scope = ['alchemy']
			case options[:scope].class.name
				when "Array"
					scope += options[:scope]
				when "String"
					scope << options[:scope]
				when "Symbol"
					scope << options[:scope] unless options[:scope] == :alchemy
			end
			::I18n.t(msg, options.merge(:scope => scope))
		end

		def self.available_locales
			translation_files.collect { |f| f.match(/.{2}\.yml$/).to_s.gsub(/\.yml/, '') }.uniq
		end

		def self.translation_files
			Rails.application.config.i18n.load_path.select { |p| p.split('/').last.match(/alchemy/) }
		end

	end
end
