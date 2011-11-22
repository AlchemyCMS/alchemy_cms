module Alchemy
	module Admin
		module BaseHelper

			def url_for_module(alchemy_module)
				if alchemy_module['controller'].starts_with?('alchemy')
					alchemy.url_for(
						:controller => alchemy_module['controller'],
						:action => alchemy_module["action"]
					)
				else
					main_app.url_for(
						:controller => alchemy_module['controller'],
						:action => alchemy_module["action"]
					)
				end
			end

		end
	end
end
