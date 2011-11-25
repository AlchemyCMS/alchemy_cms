module Alchemy
	module Admin

		class ClipboardController < Alchemy::Admin::BaseController

			def index
				clipboard = get_clipboard(params[:remarkable_type])
				@clipboard_items = model_class.all_from_clipboard(clipboard)
				respond_to do |format|
					format.html { render :layout => false }
				end
			end

			def insert
				@clipboard = get_clipboard(params[:remarkable_type])
				@item = model_class.find(params[:remarkable_id])
				unless @clipboard.collect { |i| i[:id].to_s }.include?(params[:remarkable_id])
					@clipboard.push({:id => params[:remarkable_id], :action => params[:remove] ? 'cut' : 'copy'})
				end
				respond_to do |format|
					format.js
				end
			end

			def remove
				@clipboard = get_clipboard(params[:remarkable_type])
				@item = model_class.find(params[:remarkable_id])
				@clipboard.delete_if { |i| i[:id].to_s == params[:remarkable_id] }
				respond_to do |format|
					format.js
				end
			end

			def clear
				session[:clipboard] = {}
			end

		private

			def model_class
				"alchemy/#{params[:remarkable_type]}".classify.constantize
			end

		end
	end
end