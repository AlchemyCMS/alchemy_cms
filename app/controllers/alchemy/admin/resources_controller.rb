# frozen_string_literal: true

require "csv"
require "alchemy/resource"
require "alchemy/resources_helper"
require "alchemy/resource_filter"

module Alchemy
  module Admin
    class ResourcesController < Alchemy::Admin::BaseController
      COMMON_SEARCH_FILTER_EXCLUDES = [:id, :utf8, :_method, :_, :format].freeze

      include Alchemy::ResourcesHelper

      helper Alchemy::ResourcesHelper, TagsHelper
      helper_method :resource_handler, :search_filter_params,
        :items_per_page, :items_per_page_options, :resource_has_filters,
        :resource_filters

      before_action :load_resource,
        only: [:show, :edit, :update, :destroy]

      before_action :authorize_resource

      def index
        @query = resource_handler.model.ransack(search_filter_params[:q])
        @query.sorts = default_sort_order if @query.sorts.empty?
        items = @query.result

        if contains_relations?
          items = items.includes(*resource_relations_names)
        end

        if search_filter_params[:tagged_with].present?
          items = items.tagged_with(search_filter_params[:tagged_with])
        end

        if search_filter_params[:filter].present?
          items = apply_filters(items)
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
        render action: "edit"
      end

      def edit; end

      def create
        instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.new(resource_params))
        resource_instance_variable.save
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_instance_variable.class, search_filter_params),
          flash_notice_for_resource_action,
        )
      end

      def update
        resource_instance_variable.update(resource_params)
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_instance_variable.class, search_filter_params),
          flash_notice_for_resource_action,
        )
      end

      def destroy
        resource_instance_variable.destroy
        if resource_instance_variable.errors.any?
          flash[:error] = resource_instance_variable.errors.full_messages.join(", ")
        end
        flash_notice_for_resource_action
        do_redirect_to resource_url_proxy.url_for(search_filter_params.merge(action: "index"))
      end

      def resource_handler
        @_resource_handler ||= Alchemy::Resource.new(controller_path, alchemy_module)
      end

      def resource_has_filters
        resource_model.respond_to?(:alchemy_resource_filters)
      end

      def resource_filters
        return unless resource_has_filters

        resource_model.alchemy_resource_filters.map do |filter|
          ResourceFilter.new(filter, resource_handler.resource_name)
        end
      end

      protected

      def apply_filters(items)
        sanitize_filter_params!

        search_filter_params[:filter].each do |filter|
          if argument_scope_filter?(filter)
            items = items.public_send(filter[0], filter[1])
          elsif simple_scope_filter?(filter)
            items = items.public_send(filter[1])
          else
            raise "Can't apply filter #{filter[0]}. Either the name or the values must be defined as class methods / scopes on the model."
          end
        end

        items
      end

      def simple_scope_filter?(filter)
        resource_model.respond_to?(filter[1])
      end

      def argument_scope_filter?(filter)
        resource_model.respond_to?(filter[0])
      end

      def sanitize_filter_params!
        search_filter_params[:filter].reject! do |_, v|
          eligible_resource_filter_values.exclude?(v)
        end
      end

      def eligible_resource_filter_values
        resource_filters.map(&:values).flatten
      end

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
        !alchemy_module.nil? && !alchemy_module["engine_name"].nil?
      end

      def alchemy_module
        @alchemy_module ||= module_definition_for(controller: params[:controller], action: "index")
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

      def search_filter_params
        @_search_filter_params ||= params.except(*COMMON_SEARCH_FILTER_EXCLUDES).permit(*common_search_filter_includes).to_h
      end

      def common_search_filter_includes
        search_filters = [
          { q: [
            resource_handler.search_field_name,
            :s,
          ] },
          :tagged_with,
          :page,
          :per_page,
        ]

        if resource_has_filters
          search_filters << {
            filter: resource_model.alchemy_resource_filters.map { |f| f[:name] },
          }
        end

        search_filters
      end

      def items_per_page
        cookies[:alchemy_items_per_page] = params[:per_page] || cookies[:alchemy_items_per_page] || Alchemy::Config.get(:items_per_page)
      end

      def items_per_page_options
        per_page = Alchemy::Config.get(:items_per_page)
        [per_page, per_page * 2, per_page * 4]
      end

      def default_sort_order
        name = resource_handler.attributes.detect { |attr| attr[:name] == "name" }
        name ? "name asc" : "#{resource_handler.attributes.first[:name]} asc"
      end
    end
  end
end
