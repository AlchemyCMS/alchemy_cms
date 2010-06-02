class TransitionToAuthlogic < ActiveRecord::Migration
 
  def self.up
    
    change_column :wa_users, :crypted_password, :string, :limit => 128, :null => false, :default => ""
    change_column :wa_users, :salt, :string, :limit => 128, :null => false, :default => ""
 
    rename_column :wa_users, :salt, :password_salt
    
    add_column :wa_users, :login_count, :integer, :null => false, :default => 0
    add_column :wa_users, :failed_login_count, :integer, :null => false, :default => 0
    add_column :wa_users, :last_request_at, :datetime
    add_column :wa_users, :current_login_at, :datetime
    add_column :wa_users, :last_login_at, :datetime
    add_column :wa_users, :current_login_ip, :string
    add_column :wa_users, :last_login_ip, :string
 
    add_column :wa_users, :persistence_token, :string, :null => false
    add_column :wa_users, :single_access_token, :string, :null => false
    add_column :wa_users, :perishable_token, :string, :null => false
    
    remove_column :wa_users, :remember_token
    remove_column :wa_users, :remember_token_expires_at
    
    add_index :wa_users, :perishable_token
        
  end
 
  def self.down        
    remove_column :wa_users, :perishable_token
    remove_column :wa_users, :single_access_token
    remove_column :wa_users, :persistence_token
    remove_column :wa_users, :last_login_ip
    remove_column :wa_users, :current_login_ip
    remove_column :wa_users, :last_login_at
    remove_column :wa_users, :current_login_at
    remove_column :wa_users, :last_request_at
    remove_column :wa_users, :failed_login_count
    remove_column :wa_users, :login_count    
    rename_column :wa_users, :password_salt, :salt

    add_column :wa_users, :remember_token, :string
    add_column :wa_users, :remember_token_expires_at, :datetime

  end
  
end
