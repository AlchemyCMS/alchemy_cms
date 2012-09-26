class SetAlchemyLanguagesCountryCodeDefaultToEmptyString < ActiveRecord::Migration
  def up
    without_index_for_sqlite do
      change_column :alchemy_languages, :country_code, :string, :default => '', :null => false
    end
  end

  def down
    without_index_for_sqlite do
      change_column :alchemy_languages, :country_code, :string, :default => nil, :null => true
    end
  end
  
  def without_index_for_sqlite
    if using_sqlite?
      remove_index(:alchemy_languages, [:language_code, :country_code])
      yield
      add_index(:alchemy_languages, [:language_code, :country_code])
    else
      yield
    end
  end
  
  def using_sqlite?
    ::ActiveRecord::Base.connection && ::ActiveRecord::Base.connection.adapter_name == 'SQLite'
  end
end
