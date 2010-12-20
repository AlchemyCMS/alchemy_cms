class AddDefaultToLanguages < ActiveRecord::Migration
  def self.up
    add_column :languages, :default, :boolean
  end

  def self.down
    remove_column :languages, :default
  end
end
