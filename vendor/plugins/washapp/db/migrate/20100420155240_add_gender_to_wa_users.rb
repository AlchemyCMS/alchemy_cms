class AddGenderToWaUsers < ActiveRecord::Migration
  def self.up
    add_column :wa_users, :gender, :string, :default => 'male'
  end

  def self.down
    remove_column :wa_users, :gender
  end
end
