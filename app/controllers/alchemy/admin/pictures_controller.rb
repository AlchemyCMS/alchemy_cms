# frozen_string_literal: true

module Alchemy
  module Admin
    class PicturesController < Alchemy::Admin::ResourcesController
      include UploaderResponses
      include ArchiveOverlay
      include CurrentLanguage
      include PictureDescriptionsFormHelper

      before_action :load_resource,
        only: [:edit, :update, :url, :destroy]

      before_action :set_size, only: [:index, :show, :edit_multiple, :update]

      authorize_resource class: Alchemy::Picture

      before_action(only: :assign) do
        @picture = Picture.find(params[:id])
      end

      add_alchemy_filter :by_file_format, type: :select, options: ->(query) do
        Alchemy::Picture.file_formats(query.result)
      end
      add_alchemy_filter :recent, type: :checkbox
      add_alchemy_filter :last_upload, type: :checkbox
      add_alchemy_filter :without_tag, type: :checkbox
      add_alchemy_filter :deletable, type: :checkbox

      def index
        @pictures = filtered_pictures

        if in_overlay?
          archive_overlay
        end
      end

      def show
        @pictures = filtered_pictures(per_page: 1)
        @picture = @pictures.first
        @previous = @pictures.prev_page
        @next = @pictures.next_page

        @assignments = @picture.related_ingredients.joins(element: :page)
        @picture_description = @picture.descriptions.find_or_initialize_by(
          language_id: Alchemy::Current.language.id
        )

        render action: "show"
      end

      def url
        options = picture_url_params.to_h.symbolize_keys.transform_values! do |value|
          value.in?(%w[true false]) ? value == "true" : value
        end
        render json: {
          url: @picture.url(options),
          alt: @picture.name,
          title: Alchemy.t(:image_name, name: @picture.name)
        }
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
        @tags = @pictures.collect(&:tag_list).flatten.uniq.join(", ")
      end

      def update
        @message = if @picture.update(picture_params)
          {
            body: Alchemy.t(:picture_updated_successfully, name: @picture.name),
            type: "notice"
          }
        else
          {
            body: Alchemy.t(:picture_update_failed),
            type: "error"
          }
        end
        render :update, status: (@message[:type] == "notice") ? :ok : :unprocessable_entity
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
        if params[:picture_ids].present?
          params[:picture_ids].each { DeletePictureJob.perform_later(_1) }
          flash[:notice] = Alchemy.t(:pictures_will_be_deleted_now)
        else
          flash[:warn] = Alchemy.t("Could not delete Pictures")
        end
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

      def filtered_pictures(per_page: items_per_page)
        @query = Picture.ransack(search_filter_params[:q])
        @query.sorts = default_sort_order if @query.sorts.empty?
        pictures = @query.result

        if params[:tagged_with].present?
          pictures = pictures.tagged_with(params[:tagged_with])
        end

        pictures = pictures.page(params[:page] || 1).per(per_page)
        Alchemy.storage_adapter.preloaded_pictures(pictures)
      end

      def default_sort_order
        "created_at desc"
      end

      def items_per_page
        if in_overlay?
          case @size
          when "small" then 25
          when "large" then 4
          else
            9
          end
        else
          cookies[:alchemy_pictures_per_page] = params[:per_page] ||
            cookies[:alchemy_pictures_per_page] ||
            pictures_per_page_for_size
        end
      end

      def items_per_page_options
        per_page = pictures_per_page_for_size
        [per_page, per_page * 2, per_page * 4]
      end

      private

      def set_size
        @size = params[:size] || session[:alchemy_pictures_size] || "medium"
        session[:alchemy_pictures_size] = @size
      end

      def pictures_per_page_for_size
        case @size
        when "small" then 60
        when "large" then 12
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
            :form_field_id
          ]
        )
      end

      def picture_params
        params.require(:picture).permit(
          :image_file,
          :upload_hash,
          :name,
          {
            descriptions_attributes: [
              :id,
              :text,
              :language_id,
              :picture_id
            ]
          },
          :tag_list
        )
      end

      def picture_url_params
        params.permit(
          :crop_from,
          :crop_size,
          :crop,
          :flatten,
          :format,
          :quality,
          :size,
          :upsample
        )
      end
    end
  end
end
