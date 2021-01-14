# frozen_string_literal: true

class AddDeprecatedToAlchemyElements < ActiveRecord::Migration[5.2]
  def change
    add_column :alchemy_elements, :deprecated, :boolean, null: false, default: false
    add_index :alchemy_elements, :deprecated
  end
end
