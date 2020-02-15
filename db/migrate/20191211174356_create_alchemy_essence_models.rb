class CreateAlchemyEssenceModels < ActiveRecord::Migration[6.0]
  def change
    create_table :alchemy_essence_models do |t|
      t.string "model_class"
      t.integer "model_id"
      t.datetime "created_at", null: false, precision: 6
      t.datetime "updated_at", null: false, precision: 6
      t.integer "creator_id"
      t.integer "updater_id"
      t.index ["model_class"], name: "index_alchemy_essence_models_on_model_class"
      t.index ["model_id"], name: "index_alchemy_essence_models_on_model_id"
    end
  end
end
