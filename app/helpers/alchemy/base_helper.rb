module Alchemy
	module BaseHelper

		# An alias for truncate.
		# Left here for downwards compatibilty.
		def shorten(text, length)
			text.truncate(:length => length)
		end

		# Returns @current_language set in the action (e.g. Page.show)
		def current_language
			if @current_language.nil?
				warning('@current_language is not set')
				return nil
			else
				@current_language
			end
		end

		def parse_sitemap_name(page)
			if multi_language?
				pathname = "/#{session[:language_code]}/#{page.urlname}"
			else
				pathname = "/#{page.urlname}"
			end
			pathname
		end

		# Logs a message in the Rails logger (warn level) and optionally displays an error message to the user.
		def warning(message, text = nil)
			logger.warn %(\n
				++++ WARNING: #{message}! from: #{caller.first}\n
			)
			unless text.nil?
				warning = content_tag('p', :class => 'content_editor_error') do
					render_icon('warning') + text
				end
				return warning
			end
		end

		# Taken from tinymce_hammer plugin
		def append_class_name options, class_name #:nodoc:
			key = options.has_key?('class') ? 'class' : :class 
			unless options[key].to_s =~ /(^|\s+)#{class_name}(\s+|$)/
				options[key] = "#{options[key]} #{class_name}".strip
			end
			options
		end

	end
end
