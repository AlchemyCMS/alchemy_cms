module Alchemy
  module Admin
    class WidgetConfig < Struct.new(:name, :options)

      def initialize(name, options)
        super(name.to_sym, options)
      end

      def accessible_roles
        options.fetch(:available_for) { Alchemy::Config.get(:user_roles) }.to_sym
      end

      def state
        options.fetch(:state) { :display }.to_sym
      end

      def to_partial_path
        "dashboard/widgets/widget"
      end

    end
  end
end
