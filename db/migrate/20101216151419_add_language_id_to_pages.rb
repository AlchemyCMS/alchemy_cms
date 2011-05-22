class AddLanguageIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :language_id, :integer
    rename_column :pages, :language, :language_code
    rename_column :pages, :language_root_for, :language_root
    change_column :pages, :language_root, :boolean
    execute("UPDATE pages SET language_root = 1 WHERE language_root IS NOT NULL")
    add_index :pages, :language_id
  end

  def self.down
    remove_index :pages, :language_id
    change_column :pages, :language_root, :string
    rename_column :pages, :language_root, :language_root_for
    rename_column :pages, :language_code, :language
    execute("UPDATE pages SET language_root_for = language WHERE language_root IS NOT NULL")
    remove_column :pages, :language_id
  end
end