class AddUserstampsAndTimestampsForEverything < ActiveRecord::Migration
  def self.up
    change_table :wa_images do |t|
      t.timestamps
      t.userstamps
    end
    add_column :wa_files, :updated_at, :datetime
    change_table :wa_files do |t|
      t.userstamps
    end
    change_table :wa_molecules do |t|
      t.userstamps
    end
    change_table :wa_users do |t|
      t.userstamps
    end
  end

  def self.down
    change_table :wa_images do |t|
      t.remove_timestamps
      t.remove_userstamps
    end
    change_table :wa_files do |t|
      t.remove_timestamps
      t.remove_userstamps
    end
    change_table :wa_molecules do |t|
      t.remove_timestamps
      t.remove_userstamps
    end
    change_table :wa_users do |t|
      t.remove_timestamps
      t.remove_userstamps
    end
  end
end
