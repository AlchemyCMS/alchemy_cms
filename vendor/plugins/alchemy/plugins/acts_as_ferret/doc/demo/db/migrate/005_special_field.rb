class SpecialField < ActiveRecord::Migration
  def self.up
    add_column :contents, :special, :string
  end

  def self.down
    remove_column :contents, :special
  end
end
