class AddStrippedContentToRtfAtoms < ActiveRecord::Migration
  
  def self.up
    add_column(:wa_atom_rtfs, :stripped_content, :text, :default => "")
    WaAtomRtf.reset_column_information
    WaAtomRtf.find(:all).each do |a|
      a.save
    end
  end

  def self.down
    remove_column(:wa_atom_rtfs, :stripped_content)
  end
  
end