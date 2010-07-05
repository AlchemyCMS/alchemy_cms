class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.integer :process_id, :processing_time, :open_connections
      t.string :kind, :info
      t.datetime :created_at
    end
    add_index :stats, 'kind'
  end

  def self.down
 #   remove_index :stats, 'kind'
    drop_table :stats
  end
end
