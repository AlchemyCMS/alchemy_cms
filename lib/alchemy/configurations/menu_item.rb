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

      # Legacy options of entries registered with +Alchemy::Modules.register_module+
      option :controller, :string
      option :action, :string
      option :nested_controllers, :collection, item_type: :string
      option :nested_actions, :collection, item_type: :string
      option :nested, :collection, item_type: :configuration, config_class: MenuItem

      def self.from_legacy_hash(hash)
        hash = hash.to_h.deep_stringify_keys
        new(
          from_legacy_navigation(hash["navigation"] || {}, engine_name: hash["engine_name"]).merge(
            "name" => hash["name"],
            "position" => hash["position"]
          ).compact
        )
      end

      def self.from_legacy_navigation(navigation, engine_name:)
        {
          "title" => navigation["name"],
          "engine_name" => engine_name,
          "controller" => navigation["controller"],
          "action" => navigation["action"],
          "url" => navigation["url"],
          "condition" => navigation["condition"],
          "icon" => navigation["icon"],
          "icon_style" => navigation["icon-style"],
          "image" => navigation["image"],
          "inline_image" => navigation["inline_image"],
          "turbo" => navigation.dig("data", "turbo").to_s != "false",
          "nested_controllers" => navigation["nested_controllers"],
          "nested_actions" => navigation["nested_actions"],
          "children" => navigation["sub_navigation"]&.map { |entry| new(from_legacy_navigation(entry, engine_name:)) },
          "nested" => navigation["nested"]&.map { |entry| new(from_legacy_navigation(entry, engine_name:)) }
        }.compact
      end
      private_class_method :from_legacy_navigation

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
