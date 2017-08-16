class AddPublishedAtToAlchemyPages < ActiveRecord::Migration[4.2]
  def change
    add_column :alchemy_pages, :published_at, :timestamp
  end
end
