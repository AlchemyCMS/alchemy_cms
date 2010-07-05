class CreateSharedIndex2s < ActiveRecord::Migration
  def self.up
    create_table :shared_index2s do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :shared_index2s
  end
end
