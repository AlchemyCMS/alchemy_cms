module Alchemy
	module Admin
		class AttachmentsController < Alchemy::Admin::BaseController

			protect_from_forgery :except => [:create]

			def index
				if in_overlay?
					archive_overlay
				else
					cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
					if params[:per_page] == 'all'
						@attachments = Attachment.where(cond).order(:name)
					else
						@attachments = Attachment.where(cond).paginate(
							:page => (params[:page] || 1),
							:per_page => per_page_value_for_screen_size
						).order(:name)
					end
				end
			end

			def new
				@attachment = Attachment.new
				if in_overlay?
					@while_assigning = true
					@content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
					@swap = params[:swap]
					@options = hashified_options
				end
				render :layout => false
			end

			def create
				@attachment = Attachment.new(:uploaded_data => params[:Filedata])
				@attachment.name = @attachment.filename
				@attachment.save
				cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
				if params[:per_page] == 'all'
					@attachments = Attachment.where(cond).order(:name)
				else
					@attachments = Attachment.where(cond).paginate(
						:page => (params[:page] || 1),
						:per_page => (params[:per_page] || 20)
					).order(:name)
				end
				if in_overlay?
					@while_assigning = true
					@content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
					@swap = params[:swap]
					@options = hashified_options
				end
				@message = t('File %{name} uploaded succesfully', :scope => :alchemy, :name => @attachment.name)
				# Are we using the Flash uploader? Or the plain html file uploader?
				if params[Rails.application.config.session_options[:key]].blank?
					flash[:notice] = @message
					redirect_to :action => :index
				end
			end

			def edit
				@attachment = Attachment.find(params[:id])
				render :layout => false
			end

			def update
				@attachment = Attachment.find(params[:id])
				oldname = @attachment.name
				if @attachment.update_attributes(params[:attachment])
					flash[:notice] = t("File renamed successfully from: '%{from}' to '%{to}'", :scope => :alchemy, :from => oldname, :to => @attachment.name)
				else
					render :action => "edit"
				end
				redirect_to admin_attachments_path(:page => params[:page], :query => params[:query], :per_page => params[:per_page])
			end

			def destroy
				@attachment = Attachment.find(params[:id])
				name = @attachment.name
				@attachment.destroy
				flash[:notice] = t("File: '%{name}' deleted successfully", :name => name, :scope => :alchemy)
			end

			def show
				@attachment = Attachment.find(params[:id])
				send_file(
					@attachment.public_filename,
					{
						:name => @attachment.filename,
						:type => @attachment.content_type,
						:disposition => 'inline'
					}
				)
			end

			def download
				@attachment = Attachment.find(params[:id])
				send_file(
					@attachment.full_filename, {
						:name => @attachment.filename,
						:type => @attachment.content_type,
						:disposition => 'attachment'
					}
				)
			end

		private

			def in_overlay?
				!params[:content_id].blank?
			end

			def archive_overlay
				@content = Content.find(params[:content_id])
				@options = params[:options]
				if !params[:only].blank?
					condition = "filename LIKE '%.#{params[:only].join("' OR filename LIKE '%.")}'"
				elsif !params[:except].blank?
					condition = "filename NOT LIKE '%.#{params[:except].join("' OR filename NOT LIKE '%.")}'"
				else
					condition = ""
				end
				@attachments = Attachment.where(condition).order(:name)
				respond_to do |format|
					format.html { render :partial => 'archive_overlay' }
				end
			end

		end
	end
end
