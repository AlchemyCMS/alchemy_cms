class AddSitemapStatus < ActiveRecord::Migration
  def self.up
    unless WaPage.first.respond_to?(:sitemap)
      add_column :wa_pages, :sitemap, :boolean, :default => true
      WaPage.reset_column_information
      for page in WaPage.find(:all)
        page.sitemap = page.public
        page.save!
      end
    end
  end

  def self.down
    remove_column :wa_pages, "sitemap"
  end
end