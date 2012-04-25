class AddLanguageIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :language_id, :integer
    rename_column :pages, :language, :language_code
    rename_column :pages, :language_root_for, :language_root
    # PostgreSQL does not support changing string columns to boolean.
    # We do not have existing Alchemy installations running on postgresql to support anyway,
    # so it's not critical to recreate the column.
    if ActiveRecord::Base.connection_config[:adapter] == "postgresql"
      remove_column :pages, :language_root
      add_column :pages, :language_root, :boolean
    else
      change_column :pages, :language_root, :boolean
      execute("UPDATE pages SET language_root = 1 WHERE language_root IS NOT NULL")
    end
    add_index :pages, :language_id
  end

  def self.down
    remove_index :pages, :language_id
    change_column :pages, :language_root, :string
    rename_column :pages, :language_root, :language_root_for
    execute("UPDATE pages SET language_root_for = 1 WHERE language_root_for IS NOT NULL")
    rename_column :pages, :language_code, :language
    remove_column :pages, :language_id
  end
end