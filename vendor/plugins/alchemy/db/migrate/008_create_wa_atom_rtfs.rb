class CreateWaAtomRtfs < ActiveRecord::Migration
  def self.up
    create_table :wa_atom_rtfs do |t|
      #render_content in model
      #render_editor in model
      t.column :content,  :text
    end
  end

  def self.down
    drop_table :wa_atom_rtfs
  end
end
