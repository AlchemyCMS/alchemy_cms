class AddTypeToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :type, :string
  end

  def self.down
    remove_column :contents, :type
  end
end
