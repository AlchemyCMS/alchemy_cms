class ChangeRtfText < ActiveRecord::Migration
  def self.up
    change_column(:wa_atom_rtfs, :content, :text)
  end

  def self.down
  end
end
