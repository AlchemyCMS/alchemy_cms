require_relative 'tasks/install_asset_manifests'

module Alchemy
  class Upgrader::ThreePointFour < Upgrader
    class << self
      def install_asset_manifests
        desc 'Install asset manifests into `vendor/assets`'
        Alchemy::Upgrader::Tasks::InstallAssetManifests.new.install
      end

      def alchemy_3_4_todos
        notice = <<-NOTE

        Time-based publishing
        ---------------------

        Alchemy now uses time-based publishing on the page models. Gems that
        rely on the #public method will break. If you are using an older version
        of `alchemy-pg_search`, you should now upgrade to a more recent version.

        Ref: https://github.com/AlchemyCMS/alchemy-pg_search/pull/8
        NOTE
        todo notice, 'Alchemy v3.4 changes'
      end
    end
  end
end
