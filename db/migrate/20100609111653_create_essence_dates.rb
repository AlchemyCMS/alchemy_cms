class CreateEssenceDates < ActiveRecord::Migration
  def self.up
    create_table :essence_dates do |t|
      t.datetime :date
      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :essence_dates
  end
end
