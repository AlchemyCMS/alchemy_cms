# frozen_string_literal: true

module Alchemy
  module Admin
    class PicturesController < Alchemy::Admin::ResourcesController
      include UploaderResponses

      helper 'alchemy/admin/tags'

      before_action :load_resource,
        only: [:show, :edit, :update, :destroy, :info]

      authorize_resource class: Alchemy::Picture

      def index
        @size = params[:size].present? ? params[:size] : 'medium'
        @query = Picture.ransack(params[:q])
        @pictures = Picture.search_by(params, @query, pictures_per_page_for_size(@size))

        if in_overlay?
          archive_overlay
        end
      end

      def show
        @previous = @picture.previous(params)
        @next = @picture.next(params)
        @pages = @picture.essence_pictures.group_by(&:page)
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
      rescue => e
        flash[:error] = e.message
      ensure
        redirect_to_index
      end

      def destroy
        name = @picture.name
        @picture.destroy
        flash[:notice] = Alchemy.t("Picture deleted successfully", name: name)
      rescue => e
        flash[:error] = e.message
      ensure
        redirect_to_index
      end

      private

      def pictures_per_page_for_size(size)
        case size
        when 'small'
          per_page = in_overlay? ? 25 : (per_page_value_for_screen_size * 2.9).floor
        when 'large'
          per_page = in_overlay? ? 4 : (per_page_value_for_screen_size / 1.7).floor + 1
        else
          per_page = in_overlay? ? 9 : (per_page_value_for_screen_size / 1.0).ceil + 4
        end
        per_page
      end

      def in_overlay?
        params[:element_id].present?
      end

      def archive_overlay
        @content = Content.select('id').find_by(id: params[:content_id])
        @element = Element.select('id').find_by(id: params[:element_id])

        respond_to do |format|
          format.html { render partial: 'archive_overlay' }
          format.js   { render action:  'archive_overlay' }
        end
      end

      def redirect_to_index
        do_redirect_to admin_pictures_path(search_filter_params)
      end

      def search_filter_params
        params.except(*COMMON_SEARCH_FILTER_EXCLUDES + [:picture_ids]).permit(
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
