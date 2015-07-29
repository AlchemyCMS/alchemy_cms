class AddLinkTextToAlchemyEssenceFiles < ActiveRecord::Migration
  def change
    add_column :alchemy_essence_files, :link_text, :string
  end
end
