module Alchemy
	module Admin
		class EssencePicturesController < Alchemy::Admin::BaseController

			helper "alchemy/admin/contents"

			def edit
				@essence_picture = EssencePicture.find(params[:id])
				@content = Content.find(params[:content_id])
				@options = params[:options] || {}
				render :layout => false
			end

			def crop
				@essence_picture = EssencePicture.find(params[:id])
				if @essence_picture.picture
					@content = @essence_picture.content
					@options = params[:options] || {}
					if @essence_picture.render_size.blank?
						if @options[:image_size].blank?
							@size_x, @size_y = 0, 0
						else
							@size_x, @size_y = @options[:image_size].split('x')[0], @options[:image_size].split('x')[1]
						end
					else
						@size_x, @size_y = @essence_picture.render_size.split('x')[0], @essence_picture.render_size.split('x')[1]
					end
					if @essence_picture.crop_from.blank? && @essence_picture.crop_size.blank?
						@initial_box = @essence_picture.picture.default_mask("#{@size_x}x#{@size_y}")
						@default_box = @initial_box
					else
						@initial_box = {
							:x1 => @essence_picture.crop_from.split('x')[0].to_i,
							:y1 => @essence_picture.crop_from.split('x')[1].to_i,
							:x2 => @essence_picture.crop_from.split('x')[0].to_i + @essence_picture.crop_size.split('x')[0].to_i,
							:y2 => @essence_picture.crop_from.split('x')[1].to_i + @essence_picture.crop_size.split('x')[1].to_i
						}
						@default_box = @essence_picture.picture.default_mask("#{@size_x}x#{@size_y}")
					end
					@ratio = @options[:fixed_ratio] == 'false' ? false : (@size_x.to_f / @size_y.to_f)
				else
					@no_image_notice = t('No image found. Did you saved the element?')
				end
				render :layout => false
			end

			def update
				@essence_picture = EssencePicture.find(params[:id])
				@essence_picture.update_attributes(params[:essence_picture])
				@content = Content.find(params[:content_id])
			end

			def assign
				@content = Content.find(params[:id])
				@picture = Picture.find(params[:picture_id])
				@content.essence.picture = @picture
				@options = params[:options] || {}
				@element = @content.element
				@dragable = @options[:grouped]
				# If options params come from Flash uploader then we have to parse them as hash.
				if @options.is_a?(String)
					@options = Rack::Utils.parse_query(@options)
				end
				@options = @options.merge(
					:dragable => @dragable
				)
			end

			def save_link
				@content = Content.find(params[:id])
				@picture_essence = @content.essence
				@picture_essence.link = params[:link]
				@picture_essence.link_title = params[:title]
				@picture_essence.open_link_in_new_window = params[:blank]
				@notice = t("saved_link")
				@picture_essence.save
			end

			def destroy
				content = Content.find_by_id(params[:id])
				@element = content.element
				@content_id = content.id
				content.destroy
				@essence_pictures = @element.contents.find_all_by_essence_type('Alchemy::EssencePicture')
				@options = params[:options]
			end

		end
	end
end
