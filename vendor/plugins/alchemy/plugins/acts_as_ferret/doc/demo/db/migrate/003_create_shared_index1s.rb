class CreateSharedIndex1s < ActiveRecord::Migration
  def self.up
    create_table :shared_index1s do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :shared_index1s
  end
end
