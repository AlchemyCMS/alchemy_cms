class CreateAlchemyPictureAssignments < ActiveRecord::Migration[6.0]
  def change
    unless table_exists?("alchemy_picture_assignments")
      create_table :alchemy_picture_assignments, force: :cascade do |t|
        t.references "assignee", null: false, polymorphic: true, index: false
        t.references "picture", null: false
        t.timestamps
        t.index ["assignee_id", "assigne_type", "picture_id"], name: "index_assignee_picture_uniqueness"
      end
    end
  end
end
