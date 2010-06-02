class CreateWaAtomRtfs < ActiveRecord::Migration
  def self.up
    create_table :atom_rtfs do |t|
      #render_content in model
      #render_editor in model
      t.column :content,  :text
    end
  end

  def self.down
    drop_table :atom_rtfs
  end
end
