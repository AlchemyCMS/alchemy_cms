class AddLocaleToAlchemyLanguages < ActiveRecord::Migration[4.2]
  def change
    add_column :alchemy_languages, :locale, :string
    execute \
      "UPDATE #{Alchemy::Language.table_name} SET locale = language_code WHERE locale IS NULL;"
  end
end
