# frozen_string_literal: true

class CreateDummyUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :dummy_users do |t|
      t.string :email
      t.string :password
    end
    add_index :dummy_users, :email
  end
end
