class AddFoldedToUsers < ActiveRecord::Migration
  def self.up
    remove_column :pages, :folded
    create_table "wa_foldeds" do |t|
      t.column :user_id, :integer
      t.column :page_id, :integer
      t.column :folded, :boolean, :default => false
    end
  end

  def self.down
    add_column :pages, :folded, :boolean, :default => false
    drop_table "wa_foldeds"
  end
end