module Alchemy
	class PicturesSweeper < ActionController::Caching::Sweeper
		observe Alchemy::Picture

		def after_update(picture)
			expire_cache_for(picture)
		end

		def after_destroy(picture)
			expire_cache_for(picture)
		end

	private

		def expire_cache_for(picture)
			# Removing all variants of the picture with FileUtils.
			FileUtils.rm_rf(Rails.root.join('public', Alchemy.mount_point, 'pictures', picture.id.to_s))
		end

	end
end
