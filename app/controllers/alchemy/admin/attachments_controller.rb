# frozen_string_literal: true

module Alchemy
  module Admin
    class AttachmentsController < ResourcesController
      include UploaderResponses
      include ArchiveOverlay

      add_alchemy_filter :by_file_type, type: :select,
        options: -> { Alchemy::Attachment.file_types(_1.result) }
      add_alchemy_filter :recent, type: :checkbox
      add_alchemy_filter :last_upload, type: :checkbox
      add_alchemy_filter :without_tag, type: :checkbox
      add_alchemy_filter :deletable, type: :checkbox

      before_action(only: :assign) do
        @attachment = Attachment.find(params[:id])
      end

      def index
        if arrayified_param(:only)&.one? && search_filter_params[:except].blank?
          search_filter_params[:q][:by_file_type] = mime_types_for_param(:only)
        end

        @query = Attachment.ransack(search_filter_params[:q])
        @query.sorts = default_sort_order if @query.sorts.empty?
        @attachments = @query.result

        if search_filter_params[:tagged_with].present?
          @attachments = @attachments.tagged_with(search_filter_params[:tagged_with])
        end

        if arrayified_param(:only).many?
          @attachments = @attachments.where(
            file_mime_type: mime_types_for_param(:only)
          )
        end

        if arrayified_param(:except).any?
          @attachments = @attachments.where.not(
            file_mime_type: mime_types_for_param(:except)
          )
        end

        @attachments = @attachments
          .page(params[:page] || 1)
          .per(items_per_page)

        if in_overlay?
          archive_overlay
        end
      end

      # The resources controller renders the edit form as default for show actions.
      def show
        @assignments = @attachment.related_ingredients.joins(element: :page)
        render :show
      end

      def create
        @attachment = Attachment.create(attachment_attributes)
        handle_uploader_response(status: :created)
      end

      def update
        @attachment.update(attachment_attributes)
        if attachment_attributes["file"].present?
          handle_uploader_response(status: :accepted)
        else
          render_errors_or_redirect(
            @attachment,
            admin_attachments_path(search_filter_params),
            Alchemy.t("File successfully updated")
          )
        end
      end

      def destroy
        @attachment.destroy
        flash[:notice] = Alchemy.t("File deleted successfully", name: @attachment.name)
        redirect_to alchemy.admin_attachments_path(**search_filter_params)
      end

      private

      def arrayified_param(param)
        Array.wrap(search_filter_params.fetch(param, []))
      end

      def mime_types_for_param(param)
        arrayified_param(param).map do |ext|
          Marcel::MimeType.for(extension: ext)
        end
      end

      def default_sort_order
        "created_at desc"
      end

      def search_filter_params
        @_search_filter_params ||= begin
          params[:q] ||= ActionController::Parameters.new
          params.except(*COMMON_SEARCH_FILTER_EXCLUDES + [:attachment]).permit(
            *common_search_filter_includes + [
              :form_field_id
            ],
            :only,
            {only: []},
            :except,
            {except: []}
          )
        end
      end

      def handle_uploader_response(status:)
        if @attachment.valid?
          render successful_uploader_response(file: @attachment, status: status)
        else
          render failed_uploader_response(file: @attachment)
        end
      end

      def attachment_attributes
        params.require(:attachment).permit(:file, :name, :file_name, :tag_list)
      end
    end
  end
end
