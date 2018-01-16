# frozen_string_literal: true

module Alchemy
  module Admin
    module ContentsHelper
      include Alchemy::Admin::BaseHelper

      # Renders the name of elements content.
      #
      # Displays a warning icon if content is missing its definition.
      #
      # Displays a mandatory field indicator, if the content has validations.
      #
      def render_content_name(content)
        if content.blank?
          warning('Content is nil')
          return
        end

        content_name = content.name_for_label

        if content.definition.blank?
          warning("Content #{content.name} is missing its definition")

          icon = hint_with_tooltip(
            Alchemy.t(:content_definition_missing)
          )

          content_name = "#{icon} #{content_name}".html_safe
        end

        if content.has_validations?
          "#{content_name}<span class='validation_indicator'>*</span>".html_safe
        else
          content_name
        end
      end

      # Renders the label and a remove link for a content.
      def content_label(content)
        content_tag :label do
          [render_hint_for(content), render_content_name(content)].compact.join('&nbsp;').html_safe
        end
      end
    end
  end
end
