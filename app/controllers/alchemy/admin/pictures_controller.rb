# frozen_string_literal: true

module Alchemy
  module Admin
    class PicturesController < Alchemy::Admin::ResourcesController
      include UploaderResponses
      include ArchiveOverlay

      helper 'alchemy/admin/tags'

      before_action :load_resource,
        only: [:show, :edit, :update, :destroy, :info]

      authorize_resource class: Alchemy::Picture

      def index
        @size = params[:size].present? ? params[:size] : 'medium'
        @query = Picture.ransack(search_filter_params[:q])
        @pictures = Picture.search_by(
          search_filter_params,
          @query,
          items_per_page
        )

        if in_overlay?
          archive_overlay
        end
      end

      def show
        @previous = @picture.previous(params)
        @next = @picture.next(params)
        @assignments = @picture.essence_pictures.joins(content: {element: :page})
        render action: 'show'
      end

      def create
        @picture = Picture.new(picture_params)
        @picture.name = @picture.humanized_name
        if @picture.save
          render successful_uploader_response(file: @picture)
        else
          render failed_uploader_response(file: @picture)
        end
      end

      def edit_multiple
        @pictures = Picture.where(id: params[:picture_ids])
        @tags = @pictures.collect(&:tag_list).flatten.uniq.join(', ')
      end

      def update
        if @picture.update(picture_params)
          @message = {
            body: Alchemy.t(:picture_updated_successfully, name: @picture.name),
            type: 'notice'
          }
        else
          @message = {
            body: Alchemy.t(:picture_update_failed),
            type: 'error'
          }
        end
        render :update
      end

      def update_multiple
        @pictures = Picture.find(params[:picture_ids])
        @pictures.each do |picture|
          picture.update_name_and_tag_list!(params)
        end
        flash[:notice] = Alchemy.t("Pictures updated successfully")
        redirect_to_index
      end

      def delete_multiple
        if request.delete? && params[:picture_ids].present?
          pictures = Picture.find(params[:picture_ids])
          names = []
          not_deletable = []
          pictures.each do |picture|
            if picture.deletable?
              names << picture.name
              picture.destroy
            else
              not_deletable << picture.name
            end
          end
          if not_deletable.any?
            flash[:warn] = Alchemy.t(
              "These pictures could not be deleted, because they were in use",
              names: not_deletable.to_sentence
            )
          else
            flash[:notice] = Alchemy.t("Pictures deleted successfully", names: names.to_sentence)
          end
        else
          flash[:warn] = Alchemy.t("Could not delete Pictures")
        end
      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to_index
      end

      def destroy
        name = @picture.name
        @picture.destroy
        flash[:notice] = Alchemy.t("Picture deleted successfully", name: name)
      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to_index
      end

      def items_per_page
        if in_overlay?
          case params[:size]
          when 'small' then 25
          when 'large' then 4
          else
            9
          end
        else
          cookies[:alchemy_pictures_per_page] = params[:per_page] ||
                                                cookies[:alchemy_pictures_per_page] ||
                                                pictures_per_page_for_size(params[:size])
        end
      end

      def items_per_page_options
        per_page = pictures_per_page_for_size(@size)
        [per_page, per_page * 2, per_page * 4]
      end

      private

      def pictures_per_page_for_size(size)
        case size
        when 'small' then 60
        when 'large' then 12
        else
          20
        end
      end

      def redirect_to_index
        do_redirect_to admin_pictures_path(search_filter_params)
      end

      def search_filter_params
        @_search_filter_params ||= params.except(*COMMON_SEARCH_FILTER_EXCLUDES + [:picture_ids]).permit(
          *common_search_filter_includes + [
            :size,
            :element_id,
            :swap,
            :content_id
          ]
        )
      end

      def picture_params
        params.require(:picture).permit(:image_file, :upload_hash, :name, :tag_list)
      end
    end
  end
end
