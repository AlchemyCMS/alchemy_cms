class CreateDummyModel < ActiveRecord::Migration
  def change
    create_table :dummy_models do |t|
      t.string :data
    end
  end
end
