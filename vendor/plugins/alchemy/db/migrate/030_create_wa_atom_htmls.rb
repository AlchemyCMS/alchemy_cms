class CreateWaAtomHtmls < ActiveRecord::Migration
  def self.up
    create_table "wa_atom_htmls" do |t|
      t.column :content, :text
    end
  end

  def self.down
    drop_table "wa_atom_htmls"
  end
end
