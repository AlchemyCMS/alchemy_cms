module Alchemy
  module Picture::Sweeping
    extend ActiveSupport::Concern

    included do
      after_update  { expire_cache_for(self) }
      after_destroy { expire_cache_for(self) }
    end

    private

    # Removing all variants of the picture with FileUtils.
    def expire_cache_for(picture)
      FileUtils.rm_rf(Rails.root.join('public', Alchemy::MountPoint.get.gsub(/^\//, ''), 'pictures', picture.id.to_s))
    end
  end
end
