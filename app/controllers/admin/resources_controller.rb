class Admin::ResourcesController < AlchemyController

	filter_resource_access

	rescue_from Exception, :with => :exception_handler

	before_filter :set_translation
	before_filter :find_resource, :only => [:edit, :update, :destroy]

	helper_method :resource_attributes, :resource_window_size, :resources_name, :resource_model_name

	def index
		if !params[:query].blank?
			@resources = resource_model.where(resource_attributes.map { |attribute|
				"`#{resources_name}`.#{attribute} LIKE '%#{params[:query]}%'"
			}.join(" OR "))
		else
			@resources = resource_model.all
		end
	end

	def new
		@resource = resource_model.new
		render :layout => false
	end

	def edit
		render :layout => false
	end

	def create
		@resource = resource_model.new(params[resource_model_name.to_sym])
		@resource.save
		render_errors_or_redirect(
			@resource,
			url_for({:action => :index}),
			_("Succesfully created.")
		)
	end

	def update
		@resource.update_attributes(params[resource_model_name.to_sym])
		render_errors_or_redirect(
			@resource,
			url_for({:action => :index}),
			_("Succesfully updated.")
		)
	end

	def destroy
		@resource.destroy
		flash[:notice] = _("Succesfully removed.")
	end

protected

	def find_resource
		@resource = resource_model.find(params[:id])
	end

	def resources_name
		@resources_name ||= params[:controller].split('/').last
	end

	def resource_model_name
		@resource_model_name ||= resources_name.singularize
	end

	def resource_model
		@resource_model ||= resource_model_name.classify.constantize
	end
	
	def resource_attributes
		@resource_attributes ||= @resource_model.columns.collect do |col|
			unless ["id", "updated_at", "created_at", "creator_id", "updater_id"].include?(col.name)
				{:name => col.name, :type => col.type}
			end
		end.compact
	end

	def resource_window_size
		@resource_window_size ||= "380x#{100 + resource_attributes.length * 35}"
	end

end
