# frozen_string_literal: true

module Alchemy
  module Admin
    # The button publishes the page and indicates unpublished changes if any.
    #
    # == Example
    #
    #   <%= render Alchemy::Admin::PublishPageButton.new(page: @page) %>
    #
    class PublishPageButton < ViewComponent::Base
      delegate :cannot?, :render_icon, to: :helpers
      delegate :has_unpublished_changes?, to: :page

      attr_reader :page

      def initialize(page:)
        @page = page
      end

      def disabled?
        cannot?(:publish, page) || !has_unpublished_changes?
      end

      def tooltip_content
        if !page.language.public?
          Alchemy.t(:publish_page_language_not_public)
        elsif cannot?(:publish, page)
          Alchemy.t(:publish_page_not_allowed)
        elsif !has_unpublished_changes?
          Alchemy.t(:no_unpublished_changes)
        else
          Alchemy.t(:explain_publishing)
        end
      end

      def button_label
        if page.public_version.nil?
          t(".publish_page")
        else
          t(".publish_changes")
        end
      end

      def publish_path
        Alchemy::Engine.routes.url_helpers.publish_admin_page_path(page)
      end
    end
  end
end
