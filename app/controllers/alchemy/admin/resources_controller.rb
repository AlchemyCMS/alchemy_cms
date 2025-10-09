# frozen_string_literal: true

require "csv"

module Alchemy
  module Admin
    class ResourcesController < Alchemy::Admin::BaseController
      include Alchemy::ResourcesHelper
      extend Alchemy::Admin::ResourceName
      include Alchemy::Admin::ResourceFilter

      helper Alchemy::ResourcesHelper
      helper_method :resource_handler, :items_per_page, :items_per_page_options

      before_action :load_resource,
        only: %i[show edit update destroy]

      before_action :authorize_resource

      def index
        @query = resource_handler.model.ransack(search_filter_params[:q])
        @query.sorts = default_sort_order if @query.sorts.empty?
        items = @query.result

        items = items.includes(*resource_relations_names) if contains_relations?
        items = items.tagged_with(search_filter_params[:tagged_with]) if search_filter_params[:tagged_with].present?

        respond_to do |format|
          format.html do
            items = items.page(params[:page] || 1).per(items_per_page)
            instance_variable_set(:"@#{resources_name}", items)
          end
          format.csv do
            instance_variable_set(:"@#{resources_name}", items)
          end
        end
      end

      def new
        instance_variable_set(:"@#{resource_name}", resource_handler.model.new)
      end

      def show
        render action: "edit"
      end

      def edit
      end

      def create
        instance_variable_set(:"@#{resource_name}", resource_handler.model.new(resource_params))
        resource_instance_variable.save
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_instance_variable.class, search_filter_params),
          flash_notice_for_resource_action
        )
      end

      def update
        resource_instance_variable.update(resource_params)
        render_errors_or_redirect(
          resource_instance_variable,
          resources_path(resource_instance_variable.class, search_filter_params),
          flash_notice_for_resource_action
        )
      end

      def destroy
        resource_instance_variable.destroy
        if resource_instance_variable.errors.any?
          flash[:error] = resource_instance_variable.errors.full_messages.join(", ")
        end
        flash_notice_for_resource_action
        do_redirect_to resource_url_proxy.url_for(search_filter_params.merge(action: "index", only_path: true))
      end

      def resource_handler
        @_resource_handler ||= Alchemy::Resource.new(controller_path, alchemy_module)
      end

      protected

      # Returns a translated +flash[:notice]+ for current controller action.
      def flash_notice_for_resource_action(action = action_name)
        return if resource_instance_variable.errors.any?

        flash[:notice] = message_for_resource_action(action)
      end

      # Returns a translated message for a +flash[:notice]+.
      # The key should look like "Modelname successfully created|updated|destroyed."
      def message_for_resource_action(action = action_name)
        case action.to_sym
        when :create
          verb = Alchemy.t("created", scope: "resources.actions")
        when :update
          verb = Alchemy.t("updated", scope: "resources.actions")
        when :destroy
          verb = Alchemy.t("removed", scope: "resources.actions")
        end
        Alchemy.t("%{resource_name} successfully %{action}",
          resource_name: resource_handler.model.model_name.human,
          action: verb,
          default: Alchemy.t("Successfully #{verb}"))
      end

      def is_alchemy_module?
        !alchemy_module.nil? && !alchemy_module["engine_name"].nil?
      end

      def alchemy_module
        @alchemy_module ||= module_definition_for(controller: controller_path, action: "index")
      end

      def load_resource
        instance_variable_set(:"@#{resource_name}", resource_handler.model.find(params[:id]))
      end

      def authorize_resource
        authorize!(action_name.to_sym, resource_instance_variable || resource_handler.model)
      end

      # Permits all editable resource attributes as default.
      #
      # Define this method in your inheriting controller if you want to permit additional attributes.
      #
      # @see Alchemy::Resource#editable_attributes
      def resource_params
        params.require(resource_handler.namespaced_resource_name).permit(
          resource_handler.permitted_attributes
        )
      end

      def items_per_page
        cookies[:alchemy_items_per_page] =
          params[:per_page] || cookies[:alchemy_items_per_page] || Alchemy.config.items_per_page
      end

      def items_per_page_options
        per_page = Alchemy.config.items_per_page
        [per_page, per_page * 2, per_page * 4]
      end

      def default_sort_order
        name = resource_handler.attributes.detect { |attr| attr[:name] == "name" }
        name ? "name asc" : "#{resource_handler.attributes.first[:name]} asc"
      end
    end
  end
end
