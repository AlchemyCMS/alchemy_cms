# frozen_string_literal: true

module Alchemy
  module Admin
    module FormHelper
      # Use this form helper to render any form in Alchemy admin interface.
      #
      # This is simply a wrapper for `simple_form_for`
      #
      # == Defaults
      #
      # * It uses Alchemy::Forms::Builder as builder
      # * It makes a remote request, if the request was XHR request.
      # * It adds the alchemy class to form
      #
      def alchemy_form_for(object, *args, &block)
        options = args.extract_options!
        options[:builder] = Alchemy::Forms::Builder
        options[:remote] = request.xhr?
        options[:html] = {
          id: options.delete(:id),
          class: ["alchemy", options.delete(:class)].compact.join(' ')
        }
        simple_form_for(object, *(args << options), &block)
      end
    end
  end
end
