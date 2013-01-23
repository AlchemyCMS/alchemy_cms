class MigrateToDevise < ActiveRecord::Migration
  def change
    change_table :alchemy_users do |t|
      t.rename :crypted_password, :encrypted_password
      t.rename :login_count, :sign_in_count
      t.rename :current_login_at, :current_sign_in_at
      t.rename :last_login_at, :last_sign_in_at
      t.rename :current_login_ip, :current_sign_in_ip
      t.rename :last_login_ip, :last_sign_in_ip
      t.rename :failed_login_count, :failed_attempts

      t.remove :persistence_token
      t.remove :perishable_token
      t.remove :single_access_token

      t.column :reset_password_token, :string
      t.column :reset_password_sent_at, :datetime

      t.index :email, :unique => true
      t.index :login, :unique => true
      t.index :reset_password_token, :unique => true
    end
  end
end
