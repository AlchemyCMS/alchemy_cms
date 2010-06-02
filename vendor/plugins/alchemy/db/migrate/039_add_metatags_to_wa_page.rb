class AddMetatagsToPage < ActiveRecord::Migration
  def self.up
    add_column "pages", "meta_description", :text, :default => ""
    add_column "pages", "meta_keywords", :text, :default => ""
  end

  def self.down
    remove_column "pages", "meta_description"
    remove_column "pages", "meta_keywords"
  end
end
