# frozen_string_literal: true

require 'csv'
require 'alchemy/resource'
require 'alchemy/resources_helper'

module Alchemy
  module Admin
    class ResourcesController < Alchemy::Admin::BaseController
      COMMON_SEARCH_FILTER_EXCLUDES = [:id, :utf8, :_method, :_, :format].freeze

      include Alchemy::ResourcesHelper

      helper Alchemy::ResourcesHelper, TagsHelper
      helper_method :resource_handler, :search_filter_params,
        :items_per_page, :items_per_page_options

      before_action :load_resource,
        only: [:show, :edit, :update, :destroy]

      before_action :authorize_resource

      def index
        @query = resource_handler.model.ransack(search_filter_params[:q])
        items = @query.result

        if contains_relations?
          items = items.includes(*resource_relations_names)
        end

        if search_filter_params[:tagged_with].present?
          items = items.tagged_with(search_filter_params[:tagged_with])
        end

        if search_filter_params[:filter].present?
          items = items.public_send(sanitized_filter_params)
        end

        respond_to do |format|
          format.html {
            items = items.page(params[:page] || 1).per(items_per_page)
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
        instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.new(resource_params))
        resource_instance_variable.save
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_instance_variable.class, search_filter_params),
          flash_notice_for_resource_action
        )
      end

      def update
        resource_instance_variable.update_attributes(resource_params)
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_instance_variable.class, search_filter_params),
          flash_notice_for_resource_action
        )
      end

      def destroy
        resource_instance_variable.destroy
        flash_notice_for_resource_action
        do_redirect_to resource_url_proxy.url_for(search_filter_params.merge(action: 'index'))
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
        flash[:notice] = Alchemy.t("#{resource_handler.resource_name.classify} successfully #{verb}", default: Alchemy.t("Successfully #{verb}"))
      end

      def is_alchemy_module?
        !alchemy_module.nil? && !alchemy_module['engine_name'].nil?
      end

      def alchemy_module
        @alchemy_module ||= module_definition_for(controller: params[:controller], action: 'index')
      end

      def load_resource
        instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.find(params[:id]))
      end

      def authorize_resource
        authorize!(action_name.to_sym, resource_instance_variable || resource_handler.model)
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

      def sanitized_filter_params
        resource_model.alchemy_resource_filters.detect do |filter|
          filter == search_filter_params[:filter]
        end || :all
      end

      def search_filter_params
        @_search_filter_params ||= params.except(*COMMON_SEARCH_FILTER_EXCLUDES).permit(*common_search_filter_includes).to_h
      end

      def common_search_filter_includes
        [
          # contrary to Rails' documentation passing an empty hash to permit all keys does not work
          {options: options_from_params.keys},
          {q: [
            resource_handler.search_field_name,
            :s
          ]},
          :tagged_with,
          :filter,
          :page,
          :per_page
        ].freeze
      end

      def items_per_page
        cookies[:alchemy_items_per_page] = params[:per_page] || cookies[:alchemy_items_per_page] || Alchemy::Config.get(:items_per_page)
      end

      def items_per_page_options
        per_page = Alchemy::Config.get(:items_per_page)
        [per_page, per_page * 2, per_page * 4]
      end
    end
  end
end
