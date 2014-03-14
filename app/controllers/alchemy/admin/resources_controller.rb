require 'csv'
require 'alchemy/resource'
require 'alchemy/resources_helper'
require 'handles_sortable_columns'

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

      handles_sortable_columns do |c|
        c.default_sort_value = :name
        c.link_class = 'sortable'
        c.indicator_class = {:asc => "sorted asc", :desc => "sorted desc"}
        c.indicator_text = {:asc => "<i>&nbsp;&darr;&nbsp;</i>", :desc => "<i>&nbsp;&uarr;&nbsp;</i>"}
      end

      def index
        items = resource_handler.model
        if contains_relations?
          items = items.includes(*resource_relations_names)
        end
        if params[:query].present?
          items = query_items(items)
        end
        items = items.order(sort_order)
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
        instance_variable_set("@#{resource_handler.resource_name}", resource_handler.model.new(resource_params))
        resource_instance_variable.save
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path,
          flash_notice_for_resource_action
        )
      end

      def update
        resource_instance_variable.update_attributes(resource_params)
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path,
          flash_notice_for_resource_action
        )
      end

      def destroy
        resource_instance_variable.destroy
        flash_notice_for_resource_action
        do_redirect_to resource_url_proxy.url_for(action: 'index')
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

      # Returns a sort order for AR#sort method
      #
      # Falls back to fallback_sort_order, if the requested column is not a column of model.
      #
      # If the column is a tablename and column combination that matches any resource relations, than this order will be taken.
      #
      def sort_order
        sortable_column_order do |column, direction|
          if resource_handler.model_associations.present? && column.match(/\./)
            table, column = column.split('.')
            if resource_handler.model_associations.detect { |a| a.table_name == table }
              "#{table}.#{column} #{direction}"
            else
              fallback_sort_order(direction)
            end
          elsif resource_handler.model.column_names.include?(column.to_s)
            "#{resource_handler.model.table_name}.#{column} #{direction}"
          else
            fallback_sort_order(direction)
          end
        end
      end

      # Default sort order fallback
      #
      # Overwrite this in your controller to define custom fallback
      #
      def fallback_sort_order(direction)
        "#{resource_handler.model.table_name}.id #{direction}"
      end

      # Returns an activerecord object that contains items matching params[:query]
      #
      def query_items(items)
        query = params[:query].downcase.split(' ').join('%')
        query = ActiveRecord::Base.sanitize("%#{query}%")
        items.where(search_query(query))
      end

      # Returns a search query string
      #
      # It queries all searchable attributes from resource model via LIKE and joins them via OR.
      #
      # If the attribute is a relation it builds the query for the associated table.
      #
      def search_query(search_terms)
        resource_handler.searchable_attributes.map do |attribute|
          if relation = attribute[:relation]
            "LOWER(#{relation[:model_association].klass.table_name}.#{relation[:attr_method]}) LIKE #{search_terms}"
          else
            "LOWER(#{resource_handler.model.table_name}.#{attribute[:name]}) LIKE #{search_terms}"
          end
        end.join(" OR ")
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
