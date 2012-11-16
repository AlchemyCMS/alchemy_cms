class ChangeAlchemyPicturesTagListColumn < ActiveRecord::Migration
  def up
    change_column :alchemy_pictures, :cached_tag_list, :text
  end

  def down
    change_column :alchemy_pictures, :cached_tag_list, :string
  end
end
