class AddRightGroups < ActiveRecord::Migration
  def self.up
    create_table "right_groups" do |t|
      t.column :name,   :string
    end
  end

  def self.down
    drop_table "right_groups"
  end
end
