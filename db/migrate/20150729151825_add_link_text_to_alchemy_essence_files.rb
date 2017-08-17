class AddLinkTextToAlchemyEssenceFiles < ActiveRecord::Migration[4.2]
  def change
    add_column :alchemy_essence_files, :link_text, :string
  end
end
