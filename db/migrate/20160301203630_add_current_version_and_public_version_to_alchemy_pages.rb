class AddCurrentVersionAndPublicVersionToAlchemyPages < ActiveRecord::Migration
  def up
    add_reference :alchemy_pages, :current_version, index: true
    add_foreign_key :alchemy_pages, :alchemy_page_versions, column_name: :current_version_id
    add_reference :alchemy_pages, :public_version, index: true
    add_foreign_key :alchemy_pages, :alchemy_page_versions, column_name: :public_version_id

    Alchemy::Page.find_each do |page|
      next if page.systempage? || page.redirects_to_external?
      page.build_current_version(page_id: page.id)
      if page.public?
        page.public_version = page.versions.last
      end
      page.save!
      say "Created version for Page #{page.id}"
    end
  end

  def down
    remove_reference :alchemy_pages, :current_version
    remove_foreign_key :alchemy_pages, :alchemy_page_versions
    remove_reference :alchemy_pages, :public_version
    remove_foreign_key :alchemy_pages, :alchemy_page_versions

    Alchemy::Page.find_each do |page|
      page.versions.destroy_all
      say "Removed versions from Page #{page.id}"
    end
  end
end
