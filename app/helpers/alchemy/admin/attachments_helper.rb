module Alchemy
	module Admin
		module AttachmentsHelper

			def mime_to_human mime
				Alchemy::I18n.t(mime, :scope => :mime_types, :default => t('document'))
			end

		end
	end
end
