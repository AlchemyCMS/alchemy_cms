module Alchemy
	module Admin
		class ResourcesController < Alchemy::Admin::BaseController

			rescue_from Exception, :with => :exception_handler

			before_filter :load_resource, :only => [:show, :edit, :update, :destroy]

			helper_method(
					:resource_attributes,
					:resource_window_size,
					:resources_name,
					:resource_model,
					:resource_model_name,
					:resource_instance_variable,
					:resources_instance_variable,
					:namespaced_resources_name,
					:resource_namespaced?,
					:resources_permission,
					:resource_url_scope,
					:is_alchemy_module?,

					:resource_with_scope,
					:resource_path,
					:resources_path,
					:new_resource_path,
					:edit_resource_path
			)

			def index
				if !params[:query].blank?
					search_terms = ActiveRecord::Base.sanitize("%#{params[:query]}%")
					items = resource_model.where(searchable_resource_attributes.map { |attribute|
						"`#{namespaced_resources_name}`.`#{attribute[:name]}` LIKE #{search_terms}"
					}.join(" OR "))
				else
					items = resource_model
				end
				instance_variable_set("@#{resources_name}", items.page(params[:page] || 1).per(per_page_value_for_screen_size))
			end

			def new
				instance_variable_set("@#{resource_model_name}", resource_model.new)
				render :layout => !request.xhr?
			end

			def show
				render :layout => !request.xhr?
			end

			def edit
				render :layout => !request.xhr?
			end

			def create
				instance_variable_set("@#{resource_model_name}", resource_model.new(params[resource_model_name.to_sym], :as => current_user.role.to_sym))
				resource_instance_variable.save
				render_errors_or_redirect(
						resource_instance_variable,
						resource_url_scope.url_for({:action => :index}),
						flash_notice_for_resource_action
				)
			end

			def update
				resource_instance_variable.update_attributes(params[resource_model_name.to_sym], :as => current_user.role.to_sym)
				render_errors_or_redirect(
						resource_instance_variable,
						resource_url_scope.url_for({:action => :index}),
						flash_notice_for_resource_action
				)
			end

			def destroy
				resource_instance_variable.destroy
				flash_notice_for_resource_action
			end

			protected

			# Returns a translated +flash[:notice]+.
			# The key should look like "Modelname successfully created|updated|destroyed."
			def flash_notice_for_resource_action(action = params[:action])
				case action.to_sym
					when :create
						verb = "created"
					when :update
						verb = "updated"
					when :destroy
						verb = "removed"
				end
				flash[:notice] = t("#{resource_model_name.classify} successfully #{verb}", :default => t("Succesfully #{verb}"))
			end

			def load_resource
				instance_variable_set("@#{resource_model_name}", resource_model.find(params[:id]))
			end

			def resources_name
				@_resources_name ||= resource_model_array.last
			end

			def resource_model
				@_resource_model ||= resource_model_array.join('/').classify.constantize
			end

			def resource_model_name
				@_resource_model_name ||= resources_name.singularize
			end

			def namespaced_resource_model_name
				return @_namespaced_resource_model_name unless @_namespaced_resource_model_name.nil?
				model_name_array = resource_model_array
				model_name_array.delete(alchemy_module['engine_name'])
				@_namespaced_resource_model_name = model_name_array.join('_').singularize
			end

			def resource_model_array
				resource_model_array = controller_path_array
				resource_model_array.delete("admin")
				resource_model_array
			end

			def resource_attributes
				@resource_attributes ||= resource_model.columns.collect do |col|
					unless ["id", "updated_at", "created_at", "creator_id", "updater_id"].include?(col.name)
						{:name => col.name, :type => col.type}
					end
				end.compact
			end

			def searchable_resource_attributes
				resource_attributes.select { |a| a[:type] == :string }
			end

			def resource_window_size
				@resource_window_size ||= "400x#{100 + resource_attributes.length * 35}"
			end

			def resource_instance_variable
				instance_variable_get("@#{resource_model_name}")
			end

			def resources_instance_variable
				instance_variable_get("@#{resources_name}")
			end

			def resource_namespace
				@resource_namespace ||= controller_path_array.first
			end

			def controller_path_array
				@namespace_array = controller_path.split('/')
			end

			def resource_url_scope
				if is_alchemy_module?
					eval(alchemy_module['engine_name'])
				else
					main_app
				end
			end

			def is_alchemy_module?
				!alchemy_module.nil? && !alchemy_module['engine_name'].blank?
			end

			def alchemy_module
				@alchemy_module ||= module_definition_for(:controller => params[:controller], :action => 'index')
			end

			def resources_permission
				#(resource_namespaced? ? "#{resource_namespace.underscore}_admin_#{resources_name}" : "admin_#{resources_name}").to_sym
				@_resources_permission = controller_path.gsub('/', '_').to_sym
			end


			def resources_path(resource=resource_model, options={})
				#resource_url_scope.send("#{namespaced_resources_name}_path")
				polymorphic_path (resource_scope_with_namespace + [resource]), options
			end

			def resource_path(resource=resource_model, options={})
				resources_path(resource, options)
			end

			def new_resource_path(options={})
				new_polymorphic_path (resource_scope_with_namespace + [resource_model]), options
			end

			def edit_resource_path(resource=nil, options={})
				edit_polymorphic_path (resource_scope_with_namespace+([resource] or resource_model_array)), options
			end

			def resource_scope_with_namespace
				return @resource_scope_with_namespace unless @resource_scope_with_namespace.nil?
				namespace_array = namespace_diff
				namespace_array.delete(alchemy_module['engine_name']) if is_alchemy_module?
				@resource_scope_with_namespace = [resource_url_scope].concat(namespace_array)
			end

			def namespace_diff
				controller_path_array - resource_model_array
			end

		end
	end
end
