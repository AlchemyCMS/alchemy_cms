class CreateWaAtomTexts < ActiveRecord::Migration
  def self.up
    create_table :atom_texts do |t|
          #render_content in model
          #render_editor in model      
          t.column :content,  :string
    end
  end

  def self.down
    drop_table :atom_texts
  end
end
