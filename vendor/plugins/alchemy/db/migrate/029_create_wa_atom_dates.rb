class CreateWaAtomDates < ActiveRecord::Migration
  def self.up
    create_table "atom_dates" do |t|
      t.column :date, :datetime, :default => Time.now
    end
  end

  def self.down
    drop_table "atom_dates"
  end
end
