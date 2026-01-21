class AddIndexToElementPublicationTimestamps < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  def change
    add_index :alchemy_elements, [:public_on, :public_until], algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
