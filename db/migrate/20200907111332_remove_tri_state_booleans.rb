# frozen_string_literal: true

class RemoveTriStateBooleans < ActiveRecord::Migration[6.0]
  def change
    change_column_null :alchemy_elements, :public, false, false
    change_column_default :alchemy_elements, :public, true

    change_column_null :alchemy_elements, :folded, false
    change_column_null :alchemy_elements, :unique, false

    change_column_null :alchemy_folded_pages, :folded, false

    change_column_null :alchemy_languages, :public, false
    change_column_null :alchemy_languages, :default, false

    change_column_null :alchemy_pages, :language_root, false, false
    change_column_default :alchemy_pages, :language_root, false

    change_column_null :alchemy_pages, :restricted, false
    change_column_null :alchemy_pages, :robot_index, false
    change_column_null :alchemy_pages, :robot_follow, false
    change_column_null :alchemy_pages, :sitemap, false

    change_column_null :alchemy_sites, :public, false
    change_column_null :alchemy_sites, :redirect_to_primary_host, false, false
    change_column_default :alchemy_sites, :redirect_to_primary_host, false
  end
end
