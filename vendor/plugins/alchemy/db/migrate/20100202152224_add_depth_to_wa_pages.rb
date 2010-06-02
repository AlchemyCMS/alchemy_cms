class AddDepthToWaPages < ActiveRecord::Migration
  def self.up
    add_column :wa_pages, :depth, :integer
    WaPage.reset_column_information
    WaPage.all.each{ |p| p.save }
  end

  def self.down
    remove_column :wa_pages, :depth
  end
end
