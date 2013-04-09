class CreateEvents < ActiveRecord::Migration

  def change
    create_table "events" do |t|
      t.string   "name"
      t.string   "hidden_name"
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.text     "description"
      t.decimal  "entrance_fee", :precision => 6, :scale => 2
      t.boolean  "published"
      t.integer  "location_id"
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
    end
  end

end
