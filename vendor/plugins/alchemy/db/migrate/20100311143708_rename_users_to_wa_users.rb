class RenameUsersToWaUsers < ActiveRecord::Migration

  def self.up
    rename_table :users, :wa_users
    rename_column :wa_foldeds, :user_id, :wa_user_id    
    rename_column :wa_users, :admin, :role
    change_column :wa_users, :role, :string, :default => 'registered'
    # Fucking rails raises Object is not missing constant WaUser! Great error message!
    # WaUser.reset_column_information
    # WaUser.all.each do |user|
    #   user.role = 'admin'
    #   user.save(false)
    # end
  end

  def self.down
    rename_table :wa_users, :users
    rename_column :users, :role, :admin
    change_column :users, :admin, :integer, :default => false
    rename_column :wa_foldeds, :wa_user_id, :user_id
  end
  
end
