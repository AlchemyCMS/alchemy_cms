class ChangeOpenLinkInNewWindowToLinkTarget < ActiveRecord::Migration
  def self.up
    change_column :essence_pictures, :open_link_in_new_window, :string
    change_column :essence_texts, :open_link_in_new_window, :string
    rename_column :essence_pictures, :open_link_in_new_window, :link_target
    rename_column :essence_texts, :open_link_in_new_window, :link_target
    change_column_default :essence_pictures, :link_target, nil
    change_column_default :essence_texts, :link_target, nil
  end
  
  def self.down
    change_column_default :essence_texts, :link_target, 0
    change_column_default :essence_pictures, :link_target, 0
    rename_column :essence_texts, :link_target, :open_link_in_new_window
    rename_column :essence_pictures, :link_target, :open_link_in_new_window
    change_column :essence_texts, :open_link_in_new_window, :boolean
    change_column :essence_pictures, :open_link_in_new_window, :boolean
  end
end