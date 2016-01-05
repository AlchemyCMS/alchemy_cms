class AddLocaleToAlchemyLanguages < ActiveRecord::Migration
  def change
    add_column :alchemy_languages, :locale, :string
  end
end
