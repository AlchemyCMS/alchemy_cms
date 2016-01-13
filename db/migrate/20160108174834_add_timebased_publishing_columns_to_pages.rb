class AddTimebasedPublishingColumnsToPages < ActiveRecord::Migration
  def up
    add_column :alchemy_pages, :public_on, :datetime
    add_column :alchemy_pages, :public_until, :datetime
    add_index :alchemy_pages, [:public_on, :public_until]

    Alchemy::Page.published.each do |page|
      page.update_column(public_on: page.published_at)
      say "Updated #{page.name} public state"
    end

    remove_column :alchemy_pages, :public
  end

  def down
    add_column :alchemy_pages, :public, :boolean, default: false

    Alchemy::Page.published.each do |page|
      page.update_column(public: page_public?(page))
      say "Updated #{page.name} public state"
    end

    remove_column :alchemy_pages, :public_on
    remove_column :alchemy_pages, :public_until
    remove_index :alchemy_pages, [:public_on, :public_until]
  end

  private

  def page_public?(page)
    current_time = Time.current
    page.public_on < current_time && page.public_until && page.public_until > current_time
  end
end
