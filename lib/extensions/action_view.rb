module ActionView
  module Helpers
    module FormHelper
      def button(label, options = {})
        content_tag(:button, {:type => :submit}.update(options)) do
          label.to_s
        end
      end
    end
    
    class FormBuilder
      def button(label, options = {})
        @template.button(label, options)
      end
    end
  end
end
