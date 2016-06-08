require_relative 'tasks/install_asset_manifests'

module Alchemy
  module Upgrader::ThreePointFour
    private

    def install_asset_manifests
      desc 'Install asset manifests into `vendor/assets`'
      Alchemy::Upgrader::Tasks::InstallAssetManifests.new.install
    end

    def alchemy_3_4_todos
      todo "Nothing todo for Alchemy 3.4 |o/", 'Alchemy v3.4 changes'
    end
  end
end
