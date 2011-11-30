module Alchemy
	module Admin
		module AttachmentsHelper

			def mime_to_human mime
				Alchemy::I18n.t("alchemy.mime_types.#{mime}", :default => t('document'))
			end

		end
	end
end
