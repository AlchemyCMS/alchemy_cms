class AddMetaRobotToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :robot_index, :boolean, :default => true
    add_column :pages, :robot_follow, :boolean, :default => true
    Page.reset_column_information
    Page.find_all_by_public_and_visible(true, true).each do |page|
      page.robot_index = true
      page.robot_follow = true
      page.save
    end
  end

  def self.down
    remove_column :pages, :robot_index
    remove_column :pages, :robot_follow
  end
end
