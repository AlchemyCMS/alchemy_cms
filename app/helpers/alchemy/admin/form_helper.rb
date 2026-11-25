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
      # * It adds the alchemy class to form
      # * It lists the errors of the object above the form fields.
      #   Pass +error_summary: false+ if the form displays them itself.
      #
      def alchemy_form_for(object, *args, &block)
        options = args.extract_options!
        error_summary = options.delete(:error_summary) != false
        options[:builder] = Alchemy::Forms::Builder
        options[:html] = {
          id: options.delete(:id),
          class: ["alchemy", options.delete(:class)].compact.join(" "),
          novalidate: false
        }
        simple_form_for(object, *(args << options)) do |form|
          record = form.object
          summary = if error_summary && record.respond_to?(:errors) && record.errors.any?
            content_tag("alchemy-message",
              safe_join(record.errors.full_messages.map { |message| tag.p(message) }),
              type: "error",
              icon: "warn")
          end
          safe_join([summary, capture(form, &block)])
        end
      end
    end
  end
end
