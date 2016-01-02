require 'csv'
require 'alchemy/resource'
require 'alchemy/resources_helper'

module Alchemy
  module Admin
    class ResourcesController < Alchemy::Admin::BaseController
      include Alchemy::ResourcesHelper

      helper Alchemy::ResourcesHelper
      helper_method :resource_handler

      before_filter :load_resource,
        only: [:show, :edit, :update, :destroy]

      before_filter do
        authorize!(action_name.to_sym, resource_instance_variable || resource_handler.model)
      end

      def index
        @query = resource_handler.model.ransack(params[:q])
        items = @query.result
        if contains_relations?
          items = items.includes(*resource_relations_names)
        end
        respond_to do |format|
          format.html {
            items = items.page(params[:page] || 1).per(per_page_value_for_screen_size)
            instance_variable_set("@#{resource_handler.resources_name}", items)
          }
          format.csv {
            instance_variable_set("@#{resource_handler.resources_name}", items)
          }
        end
      end

      def new
        instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.new)
      end

      def show
        render action: 'edit'
      end

      def edit; end

      def create
        instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.create(resource_params))
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_handler.resources_name, current_location_params),
          flash_notice_for_resource_action
        )
      end

      def update
        resource_instance_variable.update(resource_params)
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_handler.resources_name, current_location_params),
          flash_notice_for_resource_action
        )
      end

      def destroy
        resource_instance_variable.destroy
        flash_notice_for_resource_action
        do_redirect_to resource_url_proxy.url_for(current_location_params.merge(action: 'index'))
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
        flash[:notice] = _t("#{resource_handler.resource_name.classify} successfully #{verb}", :default => _t("Succesfully #{verb}"))
      end

      def is_alchemy_module?
        not alchemy_module.nil? and not alchemy_module['engine_name'].nil?
      end

      def alchemy_module
        @alchemy_module ||= module_definition_for(:controller => params[:controller], :action => 'index')
      end

      def load_resource
        instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.find(params[:id]))
      end

      # Permits all parameters as default!
      #
      # THIS IS INSECURE! Although only signed in admin users can send requests anyway, but we should change this.
      #
      # Please define this method in your inheriting controller and set the parameters you want to permit.
      #
      # TODO: Hook this into authorization provider.
      #
      def resource_params
        params.require(resource_handler.namespaced_resource_name).permit!
      end
    end
  end
end
