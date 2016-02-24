class AddEssenceDataToAlchemyContents < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name == 'postgresql'
      enable_extension "hstore"
      add_column :alchemy_contents, :essence_data, :hstore
      add_index :alchemy_contents, :essence_data, using: :gin
    else
      add_column :alchemy_contents, :essence_data, :text
      add_index :alchemy_contents, :essence_data
    end
  end
end
