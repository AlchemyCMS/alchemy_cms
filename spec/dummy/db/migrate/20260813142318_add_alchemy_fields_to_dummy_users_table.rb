class AddAlchemyFieldsToDummyUsersTable < ActiveRecord::Migration[7.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/postgres/i)

  def change
    add_column "dummy_users", :alchemy_roles, :text, if_not_exists: true, default: "member"
    add_column "dummy_users", :updater_id, :integer, if_not_exists: true
    add_column "dummy_users", :creator_id, :integer, if_not_exists: true
    add_index "dummy_users", :updater_id, if_not_exists: true, algorithm: algorithm
    add_index "dummy_users", :creator_id, if_not_exists: true, algorithm: algorithm
  end

  private

  def algorithm
    connection.adapter_name.match?(/postgres/i) ? :concurrently : nil
  end
end
