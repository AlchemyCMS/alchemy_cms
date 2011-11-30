module Alchemy
	module Admin
		module AttachmentsHelper

			def mime_to_human mime
				::I18n.t("alchemy.mime_types.#{mime}", :default => t('document'), :scope => :alchemy)
			end

		end
	end
end
