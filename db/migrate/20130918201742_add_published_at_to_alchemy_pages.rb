class AddPublishedAtToAlchemyPages < ActiveRecord::Migration
  def change
    add_column :alchemy_pages, :published_at, :timestamp
  end
end
