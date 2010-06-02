class RemoveDefaultForWaAtomDates < ActiveRecord::Migration
  def self.up
    change_column_default(:atom_dates, :date, nil)
  end

  def self.down
    change_column_default(:atom_dates, :date, Time.now)
  end
end
