class AddDeletedAtToAlchemyPages < ActiveRecord::Migration
  def change
    add_column :alchemy_pages, :deleted_at, :timestamp
  end
end
