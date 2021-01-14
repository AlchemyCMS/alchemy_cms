# frozen_string_literal: true

class AddDeprecatedToAlchemyContents < ActiveRecord::Migration[5.2]
  def change
    add_column :alchemy_contents, :deprecated, :boolean, default: false, null: false
    add_index :alchemy_contents, :deprecated
  end
end
