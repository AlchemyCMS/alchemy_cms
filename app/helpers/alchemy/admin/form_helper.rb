module Alchemy
  module Admin
    module FormHelper

      # Use this form helper to render any form in Alchemy admin interface.
      def alchemy_form_for(object, *args, &block)
        options = args.extract_options!
        options.merge!(builder: Alchemy::Forms::Builder, html: {class: ["alchemy", options[:class]].compact.join})
        simple_form_for(object, *(args << options), &block)
      end

    end
  end
end
