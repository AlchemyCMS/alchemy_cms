class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :login
      t.string :email
      t.string :gender
      t.string :role
      t.string :language
      t.string :crypted_password, :limit => 128, :null => false, :default => ""
      t.string :password_salt, :limit => 128, :null => false, :default => ""
      t.integer :login_count, :null => false, :default => 0
      t.integer :failed_login_count, :null => false, :default => 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip
      t.string :persistence_token, :null => false
      t.string :single_access_token, :null => false
      t.string :perishable_token, :null => false
      t.timestamps
      t.userstamps
    end
    add_index :users, :perishable_token
  end

  def self.down
    drop_table :users
  end
end
