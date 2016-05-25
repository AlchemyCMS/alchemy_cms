class AddTimebasedPublishingColumnsToPages < ActiveRecord::Migration
  def up
    add_column :alchemy_pages, :public_on, :datetime
    add_column :alchemy_pages, :public_until, :datetime
    add_index :alchemy_pages, [:public_on, :public_until]

    Alchemy::Page.each do |page|
      next unless page.published_at
      page.update_column(public_on: page.published_at)
      say "Updated #{page.name} public state"
    end

    remove_column :alchemy_pages, :public
  end

  def down
    add_column :alchemy_pages, :public, :boolean, default: false

    Alchemy::Page.each do |page|
      next unless page_public?(page)
      page.update_column(public: true)
      say "Updated #{page.name} public state"
    end

    remove_column :alchemy_pages, :public_on
    remove_column :alchemy_pages, :public_until
    remove_index :alchemy_pages, [:public_on, :public_until]
  end

  private

  def page_public?(page)
    page.public_on && page.public_on < current_time &&
      page.public_until && page.public_until > current_time
  end

  def current_time
    @_current_time ||= Time.current
  end
end
