module Alchemy
	module ResourcePathHelper

		def resource_window_size
			@resource_window_size ||= "400x#{100 + resource_attributes.length * 35}"
		end

		def resource_instance_variable
			instance_variable_get("@#{resource_model_name}")
		end

		def resources_instance_variable
			instance_variable_get("@#{resources_name}")
		end

		def resource_url_proxy
			if resource_handler.in_engine?
				eval(resource_handler.engine_name)
			else
				main_app
			end
		end

		def resource_scope
			@_resource_scope ||= [resource_url_proxy].concat(resource_handler.namespace_for_scope)
		end

		def resources_path(resource=resource_handler.model, options={})
			polymorphic_path (resource_scope + [resource]), options
		end

		def resource_path(resource=resource_handler.model, options={})
			resources_path(resource, options)
		end

		def new_resource_path(options={})
			new_polymorphic_path (resource_scope + [resource_handler.model]), options
		end

		def edit_resource_path(resource=nil, options={})
			edit_polymorphic_path (resource_scope+([resource] or model_array)), options
		end
	end
end