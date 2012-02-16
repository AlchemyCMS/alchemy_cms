class AddCountryCodeToLanguages < ActiveRecord::Migration
  def change
    add_column :alchemy_languages, :country_code, :string
    rename_column :alchemy_languages, :code, :language_code
    remove_index :alchemy_languages, :name => :index_languages_on_code
    add_index :alchemy_languages, :language_code
    add_index :alchemy_languages, [:language_code, :country_code]
  end
end
