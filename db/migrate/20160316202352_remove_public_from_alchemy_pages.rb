class RemovePublicFromAlchemyPages < ActiveRecord::Migration
  def up
    Alchemy::Page.where(public: true).each do |page|
      next if page.public_version
      page.update_columns(public_version_id: page.create_version.id)
      say "Created public version for #{page}"
    end

    remove_column :alchemy_pages, :public
  end

  def down
    add_column :alchemy_pages, :public, :boolean, default: false

    Alchemy::Page.where.not(public_version_id: nil).each do |page|
      page.update_columns(public: true)
      say "Published #{page}"
    end
  end
end
