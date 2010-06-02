class AddSitemapStatus < ActiveRecord::Migration
  def self.up
    unless Page.first.respond_to?(:sitemap)
      add_column :pages, :sitemap, :boolean, :default => true
      Page.reset_column_information
      for page in Page.find(:all)
        page.sitemap = page.public
        page.save!
      end
    end
  end

  def self.down
    remove_column :pages, "sitemap"
  end
end