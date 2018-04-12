# frozen_string_literal: true

class CreateDummyModel < ActiveRecord::Migration[4.2]
  def change
    create_table :dummy_models do |t|
      t.string :data
    end
  end
end
