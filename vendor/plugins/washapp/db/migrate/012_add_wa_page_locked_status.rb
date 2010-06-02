class AddWaPageLockedStatus < ActiveRecord::Migration
  def self.up
    add_column(:wa_pages, :locked, :boolean)
    add_column(:wa_pages, :locked_by, :string)
  end

  def self.down
    remove_column(:wa_pages, :locked)
    remove_column(:wa_pages, :locked_by)
  end
end
