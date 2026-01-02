# frozen_string_literal: true

class AddMetadataToPageVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :alchemy_page_versions, :title, :string
    add_column :alchemy_page_versions, :meta_description, :text
    add_column :alchemy_page_versions, :meta_keywords, :text
  end
end
