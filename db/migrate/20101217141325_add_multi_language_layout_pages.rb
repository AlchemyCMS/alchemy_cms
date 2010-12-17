class AddMultiLanguageLayoutPages < ActiveRecord::Migration
  def self.up
    Page.layoutpages.each do |page|
      page.language = Language.get_default
      page.save
    end
  end

  def self.down
  end
end
