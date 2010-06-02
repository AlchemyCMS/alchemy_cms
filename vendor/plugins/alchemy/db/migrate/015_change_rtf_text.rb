class ChangeRtfText < ActiveRecord::Migration
  def self.up
    change_column(:atom_rtfs, :content, :text)
  end

  def self.down
  end
end
