# frozen_string_literal: true

module Alchemy
  module Configurations
    class MenuItem < Alchemy::Configuration
      option :name, :string
      option :title, :string
      option :engine_name, :string
      option :position, :number
      option :icon, :string
      option :icon_style, :string
      option :image, :string
      option :inline_image, :string
      option :turbo, :boolean, default: true
      option :url, :proc
      option :condition, :proc
      option :match_path, :regexp
      option :children, :collection, item_type: :configuration, config_class: MenuItem

      # Legacy controller based options
      option :controller, :string
      option :action, :string
      option :nested_controllers, :collection, item_type: :string
      option :nested_actions, :collection, item_type: :string
      option :nested, :collection, item_type: :configuration, config_class: MenuItem

      def path(view_context)
        if url
          view_context.instance_exec(&url)
        elsif controller
          routes = engine_name.present? ? view_context.public_send(engine_name) : view_context.main_app
          routes.url_for(controller:, action:, only_path: true)
        end
      end

      def visible?(view_context)
        if condition
          view_context.instance_exec(&condition)
        elsif controller
          view_context.can?(action.to_sym, controller.delete_prefix("/").tr("/", "_").to_sym)
        else
          true
        end
      end

      def active?(view_context)
        current?(view_context) || children.any? { |child| child.active?(view_context) }
      end

      def current?(view_context)
        current_path = view_context.request.path
        path_matches = if match_path
          match_path.match?(current_path)
        elsif (own_path = local_path(view_context))
          current_path == own_path || current_path.start_with?("#{own_path.chomp("/")}/")
        end

        path_matches || [self, *nested].any? do |entry|
          entry.matches_controller?(controller: view_context.params[:controller], action: view_context.params[:action])
        end
      end

      def matches_controller?(controller:, action:)
        return false unless self.controller

        controller = controller.to_s.delete_prefix("/")
        action = action.to_s
        (self.controller.delete_prefix("/") == controller || nested_controllers.include?(controller)) &&
          (self.action == action || nested_actions.include?(action))
      end

      def validate_controller_existence!
        [controller, *children.map(&:controller)].compact.each do |controller|
          controller_const_name = "#{controller.camelize}Controller"
          controller_const_name.constantize
        rescue NameError
          raise "Error in AlchemyCMS module definition: '#{name}'. Could not find the " \
            "matching controller class #{controller_const_name} for the specified controller: '#{controller}'"
        end
      end

      private

      def local_path(view_context)
        uri = URI.parse(path(view_context).to_s)
        uri.path.presence if uri.host.nil? || uri.host == view_context.request.host
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
