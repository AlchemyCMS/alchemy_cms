module Alchemy
	class EssencePicture < ActiveRecord::Base

		acts_as_essence(
			:ingredient_column => :picture,
			:preview_text_method => :name
		)

		belongs_to :picture
		before_save :replace_newlines

		def replace_newlines
			return nil if caption.nil?
			caption.gsub!(/(\r\n|\r|\n)/, "<br/>")
		end

	end
end
