# frozen_string_literal: true

module Alchemy
  module Admin
    class AttachmentsController < ResourcesController
      include UploaderResponses
      include ArchiveOverlay

      add_alchemy_filter :by_file_type, type: :select, options: ->(_query, params) do
        case params&.to_h
        in {except:}
          Attachment.file_types - Attachment.file_types(from_extensions: except)
        in {only:}
          Attachment.file_types(from_extensions: only)
        else
          Attachment.file_types
        end
      end

      add_alchemy_filter :recent, type: :checkbox
      add_alchemy_filter :last_upload, type: :checkbox
      add_alchemy_filter :without_tag, type: :checkbox
      add_alchemy_filter :deletable, type: :checkbox

      before_action(only: :assign) do
        @attachment = Attachment.find(params[:id])
      end

      def index
        @query = Attachment.ransack(search_filter_params[:q])
        @query.sorts = default_sort_order if @query.sorts.empty?
        @attachments = @query.result

        if search_filter_params[:tagged_with].present?
          @attachments = @attachments.tagged_with(search_filter_params[:tagged_with])
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
        @assignments = @attachment.related_ingredients.joins(element: :page).merge(PageVersion.drafts)
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

      def default_sort_order
        "created_at desc"
      end

      def search_filter_params
        @_search_filter_params ||= begin
          params[:q] ||= ActionController::Parameters.new

          if params[:only].present?
            params[:q][:by_file_type] ||= Array(params[:only]).map do |extension|
              Marcel::MimeType.for(extension:)
            end
          end

          if params[:except].present?
            params[:q][:by_file_type] ||= Attachment.file_types - params[:except].map do |extension|
              Marcel::MimeType.for(extension:)
            end
          end

          params.except(*COMMON_SEARCH_FILTER_EXCLUDES + [:attachment]).permit(
            *common_search_filter_includes + [
              :form_field_id,
              {only: []},
              {except: []}
            ]
          )
        end
      end

      def permitted_ransack_search_fields
        super + [
          {by_file_type: []},
          :not_file_type,
          {not_file_type: []}
        ]
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
