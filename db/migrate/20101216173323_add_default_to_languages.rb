class AddDefaultToLanguages < ActiveRecord::Migration
  def self.up
    add_column :languages, :default, :boolean
    Language.reset_column_information
    lang = Language.first
    lang.default = true
    lang.save(false)
  end

  def self.down
    remove_column :languages, :default
  end
end
