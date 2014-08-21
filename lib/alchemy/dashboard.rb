module Alchemy
  module Admin
    class Dashboard
      @@widget_configs = []

      def self.register_widget(name, opts={})
        options = opts.reverse_merge(state: :dashboard)
        @@widget_configs << WidgetConfig.new(name, options)
      end

      def setup_widgets(controller_class)
        return self if @initialized
        controller_class.has_widgets do |root|
          @@widget_configs.each do |wc|
            root << widget(wc.name, wc.options.merge(current_alchemy_user: current_alchemy_user))
          end
        end
        @initialized = true
        self
      end

      def widget_configs
        @@widget_configs
      end

    end
  end
end
