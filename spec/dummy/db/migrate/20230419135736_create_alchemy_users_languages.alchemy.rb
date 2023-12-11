# frozen_string_literal: true

# This migration comes from alchemy (originally 20230407153522)
class CreateAlchemyUsersLanguages < ActiveRecord::Migration[6.1]
  def change
    create_table :alchemy_users_languages do |t|
      t.bigint :user_id, null: false
      t.bigint :language_id, full: false

      t.index :user_id
      t.index :language_id
    end
  end
end
