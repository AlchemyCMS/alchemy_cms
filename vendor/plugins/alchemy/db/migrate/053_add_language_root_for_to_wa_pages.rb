class AddLanguageRootForToWaPages < ActiveRecord::Migration
  def self.up
    add_column :wa_pages, :language_root_for, :string
    add_column :wa_pages, :language, :string
  end

  def self.down
    remove_column :wa_pages, :language
    remove_column :wa_pages, :language_root_for
  end
end
