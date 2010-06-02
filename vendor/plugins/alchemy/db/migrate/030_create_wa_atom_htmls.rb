class CreateWaAtomHtmls < ActiveRecord::Migration
  def self.up
    create_table "atom_htmls" do |t|
      t.column :content, :text
    end
  end

  def self.down
    drop_table "atom_htmls"
  end
end
