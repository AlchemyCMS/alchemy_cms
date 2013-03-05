module Alchemy
  module Admin
    class PicturesController < Alchemy::Admin::BaseController
      protect_from_forgery :except => [:create]

      cache_sweeper Alchemy::PicturesSweeper, :only => [:update, :destroy]

      respond_to :html, :js

      def index
        @size = params[:size].present? ? params[:size] : 'medium'
        @pictures = Picture.scoped
        @pictures = @pictures.tagged_with(params[:tagged_with]) if params[:tagged_with].present?
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
          @content = Content.find_by_id(params[:content_id], :select => 'id')
          @element = Element.find(params[:element_id], :select => 'id')
          @options = hashified_options
          @page = params[:page]
          @per_page = params[:per_page]
        end
        render :layout => false
      end

      def create
        @picture = Picture.new(
          :image_file => params[:Filedata],
          :upload_hash => params[:upload_hash]
        )
        @picture.name = @picture.humanized_name
        @picture.save!
        @size = params[:size] || 'medium'
        if in_overlay?
          @while_assigning = true
          @content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
          @element = Element.find(params[:element_id], :select => 'id')
          @options = hashified_options
          @page = params[:page] || 1
          @per_page = pictures_per_page_for_size(@size)
        end
        @pictures = Picture.find_paginated(params, pictures_per_page_for_size(@size))
        @message = _t('Picture uploaded succesfully', :name => @picture.name)
        # Are we using the single file uploader?
        if params[Rails.application.config.session_options[:key]].blank?
          flash[:notice] = @message
          redirect_to admin_pictures_path(:filter => 'last_upload')
        else
          # Or the mutliple file uploader?
          render # create.js.erb template
        end
      end

      def show
        @picture = Picture.find(params[:id])
        render :layout => false
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
          flash[:notice] = _t('picture_updated_successfully', :name => @picture.name)
        else
          flash[:error] = _t('picture_update_failed')
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
        flash[:notice] = _t("Pictures updated successfully")
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
            flash[:warn] = _t("These pictures could not be deleted, because they where in use", :names => not_deletable.to_sentence)
          else
            flash[:notice] = _t("Pictures deleted successfully", :names => names.to_sentence)
          end
        else
          flash[:warn] = _t("Could not delete Pictures")
        end
      rescue Exception => e
        flash[:error] = e.message
      ensure
        redirect_to_index
      end

      def destroy
        @picture = Picture.find(params[:id])
        name = @picture.name
        @picture.destroy
        flash[:notice] = _t("Picture deleted successfully", :name => name)
      rescue Exception => e
        flash[:error] = e.message
      ensure
        @redirect_url = admin_pictures_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
        render :redirect
      end

      def flush
        # FileUtils.rm_rf only takes arrays of folders...
        FileUtils.rm_rf Dir.glob(Rails.root.join('public', Alchemy.mount_point, 'pictures', '*'))
        @notice = _t('Picture cache flushed')
      end

      def info
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
          per_page = in_overlay? ? 9 : (per_page_value_for_screen_size / 1.0).ceil + 4
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
            render :action => 'archive_overlay'
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
