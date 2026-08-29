# frozen_string_literal: true

module Alchemy
  module Admin
    module ArchiveOverlay
      # Sets assignable id on given form field via JS.
      #
      # When the user saves the model the assignable
      # gets persisted with the model as well.
      #
      def assign
        @assignable_id = params[:id]
        @form_field_id = params[:form_field_id]
      end

      private

      def in_overlay?
        params[:form_field_id].present?
      end

      def archive_overlay
        @form_field_id = params[:form_field_id]

        respond_to do |format|
          format.html { render partial: "archive_overlay", locals: archive_overlay_locals }
        end
      end

      def archive_overlay_locals
        {form_field_id: @form_field_id}
      end
    end
  end
end
