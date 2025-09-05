# This migration comes from alchemy (originally 20250905140323)
class AddCreatedAtIndexToPicturesAndAttachments < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  def change
    add_index :alchemy_pictures, :created_at, if_not_exists: true, algorithm: algorithm
    add_index :alchemy_attachments, :created_at, if_not_exists: true, algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
