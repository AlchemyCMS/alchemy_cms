class MovePageMetaDataToPageVersions < ActiveRecord::Migration
  def up
    add_column :alchemy_page_versions, :meta_keywords, :string
    add_column :alchemy_page_versions, :meta_description, :string

    Alchemy::Page.contentpages.each do |page|
      version = page.public_version || page.current_version
      next unless version
      version.update_columns(
        title: page.title,
        meta_keywords: page.meta_keywords,
        meta_description: page.meta_description
      )
      say "Moves meta data from #{page} to #{version}"
    end

    remove_column :alchemy_pages, :title
    remove_column :alchemy_pages, :meta_keywords
    remove_column :alchemy_pages, :meta_description
  end

  def down
    add_column :alchemy_pages, :title, :string
    add_column :alchemy_pages, :meta_keywords, :string
    add_column :alchemy_pages, :meta_description, :string

    Alchemy::Page.contentpages.each do |page|
      version = page.public_version || page.current_version
      next unless version
      page.update_columns(
        title: version.title,
        meta_keywords: version.meta_keywords,
        meta_description: version.meta_description
      )
      say "Moves meta data from #{version} to #{page}"
    end

    remove_column :alchemy_page_versions, :meta_keywords
    remove_column :alchemy_page_versions, :meta_description
  end
end
