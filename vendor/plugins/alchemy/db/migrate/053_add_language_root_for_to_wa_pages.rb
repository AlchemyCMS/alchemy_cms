class AddLanguageRootForToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :language_root_for, :string
    add_column :pages, :language, :string
  end

  def self.down
    remove_column :pages, :language
    remove_column :pages, :language_root_for
  end
end
