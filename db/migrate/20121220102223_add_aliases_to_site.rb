class AddAliasesToSite < ActiveRecord::Migration
  def change
    add_column :alchemy_sites, :aliases, :text
    add_column :alchemy_sites, :redirect_to_primary_host, :boolean
  end
end
