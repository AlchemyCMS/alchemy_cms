# frozen_string_literal: true

module Alchemy
  module Admin
    module PreviewTime
      extend ActiveSupport::Concern

      included do
        before_action :set_preview_time, if: :should_set_preview_time?
      end

      private

      def set_preview_time
        Current.preview_time = Time.zone.parse(params[:alchemy_preview_time])
      end

      def should_set_preview_time?
        params[:alchemy_preview_time].present? && can?(:edit_content, Alchemy::Page)
      end
    end
  end
end
