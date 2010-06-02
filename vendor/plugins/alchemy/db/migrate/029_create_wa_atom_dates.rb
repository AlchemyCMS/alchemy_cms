class CreateWaAtomDates < ActiveRecord::Migration
  def self.up
    create_table "wa_atom_dates" do |t|
      t.column :date, :datetime, :default => Time.now
    end
  end

  def self.down
    drop_table "wa_atom_dates"
  end
end
