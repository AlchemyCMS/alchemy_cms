class AddPageLockedStatus < ActiveRecord::Migration
  def self.up
    add_column(:pages, :locked, :boolean)
    add_column(:pages, :locked_by, :string)
  end

  def self.down
    remove_column(:pages, :locked)
    remove_column(:pages, :locked_by)
  end
end
