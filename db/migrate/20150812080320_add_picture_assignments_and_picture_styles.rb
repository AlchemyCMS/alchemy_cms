class AddPictureAssignmentsAndPictureStyles < ActiveRecord::Migration
  def change
    create_table :alchemy_picture_assignments do |t|
      t.integer  :picture_id
      t.integer  :assignable_id
      t.string   :assignable_type
      t.timestamps null: false
      t.integer  :creator_id
      t.integer  :updater_id
    end

    add_index :alchemy_picture_assignments, [:assignable_id, :assignable_type],
      name: :index_picture_assignments_on_assignable_type_and_assignable_id

    create_table :alchemy_picture_styles do |t|
      t.integer :picture_assignment_id
      t.string :crop_from
      t.string :crop_size
      t.string :render_size
      t.timestamps null: false
      t.integer :creator_id
      t.integer :updater_id
    end

    add_index :alchemy_picture_styles, :picture_assignment_id

    remove_column :alchemy_essence_pictures, :picture_id
    remove_column :alchemy_essence_pictures, :crop_from
    remove_column :alchemy_essence_pictures, :crop_size
    remove_column :alchemy_essence_pictures, :render_size
  end
end


