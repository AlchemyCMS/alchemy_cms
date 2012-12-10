module Alchemy
  module Admin
    class ResourcesController < Alchemy::Admin::BaseController

      include Alchemy::ResourcesHelper
      helper Alchemy::ResourcesHelper
      helper_method :resource_handler

      before_filter :load_resource, :only => [:show, :edit, :update, :destroy]

      def index
        if params[:query].blank?
          items = resource_handler.model
        else
          search_terms = ActiveRecord::Base.sanitize("%#{params[:query]}%")
          items = resource_handler.model.where(resource_handler.searchable_attributes.map { |attribute|
            "`#{resource_handler.model.table_name}`.`#{attribute[:name]}` LIKE #{search_terms}"
          }.join(" OR "))
        end
        instance_variable_set("@#{resource_handler.resources_name}", items.page(params[:page] || 1).per(per_page_value_for_screen_size))
      end

      def new
        instance_variable_set("@#{resource_handler.model_name}", resource_handler.model.new)
        render :layout => !request.xhr?
      end

      def show
        render :layout => !request.xhr?
      end

      def edit
        render :layout => !request.xhr?
      end

      def create
        instance_variable_set("@#{resource_handler.model_name}", resource_handler.model.new(params[resource_handler.namespaced_model_name.to_sym]))
        resource_instance_variable.save
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path,
          flash_notice_for_resource_action
        )
      end

      def update
        resource_instance_variable.update_attributes(params[resource_handler.namespaced_model_name.to_sym])
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path,
          flash_notice_for_resource_action
        )
      end

      def destroy
        resource_instance_variable.destroy
        flash_notice_for_resource_action
      end

      def resource_handler
        @_resource_handler ||= Alchemy::Resource.new(controller_path, alchemy_module)
      end

    protected

      # Returns a translated +flash[:notice]+.
      # The key should look like "Modelname successfully created|updated|destroyed."
      def flash_notice_for_resource_action(action = params[:action])
        return if resource_instance_variable.errors.any?
        case action.to_sym
        when :create
          verb = "created"
        when :update
          verb = "updated"
        when :destroy
          verb = "removed"
        end
        flash[:notice] = t("#{resource_handler.model_name.classify} successfully #{verb}", :default => t("Succesfully #{verb}"))
      end

      def is_alchemy_module?
        not alchemy_module.nil? and not alchemy_module['engine_name'].nil?
      end

      def alchemy_module
        @alchemy_module ||= module_definition_for(:controller => params[:controller], :action => 'index')
      end

      def load_resource
        instance_variable_set("@#{resource_handler.model_name}", resource_handler.model.find(params[:id]))
      end
    end
  end
end
