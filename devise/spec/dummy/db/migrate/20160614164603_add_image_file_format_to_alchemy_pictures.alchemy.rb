# This migration comes from alchemy (originally 20160422195310)
class AddImageFileFormatToAlchemyPictures < ActiveRecord::Migration
  def up
    add_column :alchemy_pictures, :image_file_format, :string

    say_with_time "Storing file format of existing pictures" do
      Alchemy::Picture.all.each do |pic|
        begin
          format = pic.image_file.identify('-ping -format "%m"')
          pic.update_column('image_file_format', format.to_s.downcase)
        rescue Dragonfly::Job::Fetch::NotFound => e
          say(e.message, true)
        end
      end
      Alchemy::Picture.count
    end
  end

  def down
    remove_column :alchemy_pictures, :image_file_format
  end
end
