module Alchemy
  module Admin
    class PicturesController < Alchemy::Admin::BaseController
      protect_from_forgery :except => [:create]

      cache_sweeper Alchemy::PicturesSweeper, :only => [:update, :destroy]

      respond_to :html, :js

      def index
        @size = params[:size].present? ? params[:size] : 'medium'
        @pictures = Picture.scoped
        @pictures = @pictures.tagged_with(params[:tagged_with], :any => true) if params[:tagged_with].present?
        case params[:filter]
          when 'recent'
            @pictures = @pictures.recent
          when 'last_upload'
            @pictures = @pictures.last_upload
        end
        @pictures = @pictures.find_paginated(params, pictures_per_page_for_size(@size))
        if in_overlay?
          archive_overlay
        else
          # render index.html.erb
        end
      end

      def new
        @picture = Picture.new
        @while_assigning = params[:while_assigning] == 'true'
        @size = params[:size] || 'medium'
        if in_overlay?
          @while_assigning = true
          @content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
          @element = Element.find(params[:element_id], :select => 'id')
          @options = hashified_options
          @page = params[:page]
          @per_page = params[:per_page]
        end
        render :layout => false
      end

      def create
        @picture = Picture.new(:image_file => params[:Filedata], :upload_hash => params[:hash], :tag_list => params[:picture].try(:[],:tag_list))
        @picture.name = @picture.humanized_name
        @picture.save
        @size = params[:size] || 'medium'
        if in_overlay?
          @while_assigning = true
          @content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
          @element = Element.find(params[:element_id], :select => 'id')
          @options = hashified_options
          @page = params[:page] || 1
          @per_page = pictures_per_page_for_size(@size)
        end
        @pictures = Picture.last_upload.find_paginated(params, pictures_per_page_for_size(@size))
        @message = t('Picture uploaded succesfully', :name => @picture.name)
        # Are we using the Flash uploader? Or the plain html file uploader?
        if params[Rails.application.config.session_options[:key]].blank?
          flash[:notice] = @message
          #redirect_to :back
          #TODO temporary workaround; has to be fixed.
          redirect_to admin_pictures_path(:filter => 'last_upload')
        end
      end

      def edit
        @picture = Picture.find(params[:id])
        render :layout => !request.xhr?
      end

      def edit_multiple
        @pictures = Picture.find(params[:picture_ids])
        render :layout => !request.xhr?
      end

      def update
        @picture = Picture.find(params[:id])

        if @picture.update_attributes(params[:picture])
          flash[:notice] = t('picture_updated_successfully', :name => @picture.name)
        else
          flash[:error] = t('picture_update_failed')
        end
        redirect_to_index
      end

      def update_multiple
        @pictures = Picture.find(params[:picture_ids])
        @pictures.each do |picture|
          # Do not delete name from multiple pictures, if the form field is blank!
          picture.name = params[:pictures_name] if params[:pictures_name].present?
          picture.tag_list = params[:pictures_tag_list]
          picture.save
        end
        flash[:notice] = t("Pictures updated successfully")
        redirect_to_index
      end

      def delete_multiple
        if request.delete? && params[:picture_ids].present?
          pictures = Picture.find(params[:picture_ids])
          names = pictures.map(&:name).to_sentence
          pictures.each do |picture|
            picture.destroy
          end
          flash[:notice] = t("Pictures deleted successfully", :names => names)
        else
          flash[:notice] = t("Could not delete Pictures")
        end
        redirect_to_index
      end

      def destroy
        @picture = Picture.find(params[:id])
        name = @picture.name
        @picture.destroy
        flash[:notice] = t("Picture deleted successfully", :name => name)
        @redirect_url = admin_pictures_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
        render :action => :redirect
      end

      def flush
        FileUtils.rm_rf Rails.root.join('public', Alchemy.mount_point, 'pictures')
        @notice = t('Picture cache flushed')
      end

      def show_in_window
        @picture = Picture.find(params[:id])
        render :layout => false
      end

    private

      def pictures_per_page_for_size(size)
        case size
        when 'small'
          per_page = in_overlay? ? 37 : (per_page_value_for_screen_size * 2.9).floor
        when 'large'
          per_page = in_overlay? ? 4 : (per_page_value_for_screen_size / 1.7).floor + 1
        else
          per_page = in_overlay? ? 9 : (per_page_value_for_screen_size / 1.0).ceil + 1
        end
        return per_page
      end

      def in_overlay?
        !params[:element_id].blank?
      end

      def archive_overlay
        @content = Content.find_by_id(params[:content_id], :select => 'id')
        @element = Element.find_by_id(params[:element_id], :select => 'id')
        @options = hashified_options
        respond_to do |format|
          format.html {
            render :partial => 'archive_overlay'
          }
          format.js {
            render :action => :archive_overlay
          }
        end
      end

      def redirect_to_index
        redirect_to(
          :action => :index,
          :query => params[:query],
          :tagged_with => params[:tagged_with],
          :size => params[:size],
          :filter => params[:filter]
        )
      end

    end
  end
end
