class AddMetaRobotToWaPages < ActiveRecord::Migration
  def self.up
    add_column :wa_pages, :robot_index, :boolean, :default => true
    add_column :wa_pages, :robot_follow, :boolean, :default => true
    WaPage.reset_column_information
    WaPage.find_all_by_public_and_visible(true, true).each do |page|
      page.robot_index = true
      page.robot_follow = true
      page.save
    end
  end

  def self.down
    remove_column :wa_pages, :robot_index
    remove_column :wa_pages, :robot_follow
  end
end
