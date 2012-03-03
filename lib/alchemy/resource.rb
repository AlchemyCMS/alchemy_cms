require 'active_support/inflector'

module Alchemy
	class Resource

		SKIP_ATTRIBUTES = %W[id updated_at created_at creator_id updater_id]

		def initialize(controller_path, module_definition=nil)
			@controller_path = controller_path
			@module_definition = module_definition
		end

		def model_array
			model_array = controller_path_array
			model_array.delete("admin")
			model_array
		end

		def model
			@_model ||= model_array.join('/').classify.constantize
		end

		def resources_name
			@_resources_name ||= model_array.last
		end

		def model_name
			@_model_name ||= resources_name.singularize
		end

		def permission_scope
			#(resource_namespaced? ? "#{resource_namespace.underscore}_admin_#{resources_name}" : "admin_#{resources_name}").to_sym
			@_permission = @controller_path.gsub('/', '_').to_sym
		end

		def namespace_for_scope
			namespace_array = namespace_diff
			namespace_array.delete(engine_name) if in_engine?
			namespace_array
		end

		def attributes
			#@_attributes ||=
			self.model.columns.collect do |col|
				skip_attributes = defined?(self.model.SKIP_ATTRIBUTES) ? self.model.SKIP_ATTRIBUTES : SKIP_ATTRIBUTES
				unless skip_attributes.include?(col.name)
					{:name => col.name, :type => col.type}
				end
			end.compact
		end

		def searchable_attributes
			self.attributes.select { |a| a[:type] == :string }
		end

		def namespaced_model_name
			return @_namespaced_model_name unless @_namespaced_model_name.nil?
			model_name_array = self.model_array
			model_name_array.delete(self.engine_name) if in_engine?
			@_namespaced_model_name = model_name_array.join('_').singularize
		end

		def in_engine?
			not self.engine_name.nil?
		end

		def engine_name
			@module_definition and @module_definition['engine_name']
		end

		protected

		def controller_path_array
			@controller_path.split('/')
		end

		def namespace_diff
			controller_path_array - model_array
		end

	end
end