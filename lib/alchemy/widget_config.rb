module Alchemy
  module Admin
    class WidgetConfig < Struct.new(:name, :options)
      # include ActiveModel::Conversion

      def initialize(name, options)
        super(name.to_sym, options)
      end

      # attr_accessor :available_for
      # @@available_for = Alchemy::Config.get(:user_roles)

      # def self.register
      #   widget = new
      #   yield widget
      #   Dashboard.register_widget(widget)
      # end

      # def accessible_roles
      #   available_for || @@available_for
      # end

      def state
        options.fetch(:state) { :display }.to_sym
      end

      def to_partial_path
        "dashboard/widgets/widget"
      end

    end
  end
end
