require_relative 'tasks/install_asset_manifests'

module Alchemy
  class Upgrader::ThreePointFour < Upgrader
    def self.install_asset_manifests
      desc 'Install asset manifests into `vendor/assets`'
      Alchemy::Upgrader::Tasks::InstallAssetManifests.new.install
    end
  end
end
