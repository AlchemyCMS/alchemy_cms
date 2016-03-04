class AddCurrentVersionAndPublicVersionToAlchemyPages < ActiveRecord::Migration
  def up
    add_reference :alchemy_pages, :current_version, index: true
    add_reference :alchemy_pages, :public_version, index: true

    add_foreign_key :alchemy_pages, :alchemy_page_versions,
      column_name: :current_version_id,
      on_update: :cascade,
      name: :alchemy_pages_current_version_id_fkey

    add_foreign_key :alchemy_pages, :alchemy_page_versions,
      column_name: :public_version_id,
      on_update: :cascade,
      name: :alchemy_pages_public_version_id_fkey
  end

  def down
    remove_reference :alchemy_pages, :current_version
    remove_reference :alchemy_pages, :public_version

    remove_foreign_key :alchemy_pages, :alchemy_page_versions,
      name: :alchemy_pages_current_version_id_fkey

    remove_foreign_key :alchemy_pages, :alchemy_page_versions,
      name: :alchemy_pages_public_version_id_fkey
  end
end
