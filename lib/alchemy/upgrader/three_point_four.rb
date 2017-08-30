require_relative 'tasks/install_asset_manifests'

module Alchemy
  class Upgrader::ThreePointFour < Upgrader
    def self.install_asset_manifests
      desc 'Install asset manifests into `vendor/assets`'
      Alchemy::Upgrader::Tasks::InstallAssetManifests.new.install
    end

    def self.store_image_file_format
      desc 'Store image file format'
      pictures = Alchemy::Picture.where(image_file_format: nil)
      count = pictures.size
      converted_pics = 0
      errored_pics = 0
      puts "-- Storing file format of #{count} pictures"
      pictures.find_each(batch_size: 100).with_index do |pic, i|
        begin
          puts "   -> Reading file format of #{pic.image_file_name} (#{i + 1}/#{count})"
          format = pic.image_file.identify('-ping -format "%m"')
          pic.update_column('image_file_format', format.to_s.chomp.downcase)
          converted_pics += 1
        rescue Dragonfly::Job::Fetch::NotFound => e
          puts "   -> #{e.message}"
          errored_pics += 1
        end
      end
      puts "-- Done! Converted #{converted_pics} images."
      unless errored_pics.zero?
        puts "   !! But #{errored_pics} images caused errors."
        puts "      Please check errors above and re-run `rake alchemy:upgrade:3.4:store_image_file_format`"
      end
    end
  end
end
