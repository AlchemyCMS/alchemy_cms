module Alchemy
  module Admin
    class Dashboard

      # attr_reader :widgets
      @@widgets = []

      def self.register_widget(name, opts={})
        options = opts.reverse_merge(state: :dashboard)
        @@widgets << WidgetConfig.new(name, options)
      end

      def setup_widgets(controller_class)
        # return if initialized?
        controller_class.has_widgets do |root|
          @@widgets.each do |wc|
            root << widget(wc.name, wc.options.merge(current_alchemy_user: current_alchemy_user))
          end
        end
        self
      end

      def widgets
        @@widgets
      end

    end
  end
end
