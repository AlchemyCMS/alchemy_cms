# This migration comes from alchemy (originally 20260702090038)
class AddIndexToElementsPagesJoinTable < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  def change
    add_index :alchemy_elements_alchemy_pages, :element_id, if_not_exists: true, algorithm: algorithm
    add_index :alchemy_elements_alchemy_pages, :page_id, if_not_exists: true, algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
