# frozen_string_literal: true

module Alchemy
  module OnPageLayout
    # Runs OnPageLayout callbacks
    #
    # Included in +Alchemy::PagesController+ and +Alchemy::Admin::PagesController+
    #
    # @see OnPageLayout in order to learn how to define +on_page_layout+ callbacks.
    #
    module CallbacksRunner
      private

      def run_on_page_layout_callbacks?
        OnPageLayout.callbacks.present?
      end

      def run_on_page_layout_callbacks
        OnPageLayout.callbacks.each do |page_layout, callbacks|
          next unless call_page_layout_callback_for?(page_layout)
          callbacks.each do |callback|
            if callback.respond_to?(:call)
              instance_eval(&callback)
            else
              send(callback)
            end
          end
        end
      end

      def call_page_layout_callback_for?(page_layout)
        page_layout.to_sym == :all || @page.page_layout.to_sym == page_layout.to_sym
      end
    end
  end
end
