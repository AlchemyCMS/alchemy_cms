class SetAlchemyLanguagesCountryCodeDefaultToEmptyString < ActiveRecord::Migration
  def up
    Alchemy::Language.connection.execute("UPDATE `alchemy_languages` SET `country_code` = '' WHERE `country_code` IS NULL")
    change_column :alchemy_languages, :country_code, :string, :default => '', :null => false
  end

  def down
    change_column :alchemy_languages, :country_code, :string, :default => nil, :null => true
  end
end
