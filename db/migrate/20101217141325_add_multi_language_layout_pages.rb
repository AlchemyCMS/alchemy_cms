class AddMultiLanguageLayoutPages < ActiveRecord::Migration
  def self.up
    Page.layoutpages.each do |page|
      page.language = Language.get_default
      page.language_code = page.language.code
      page.save
    end
  end

  def self.down
  end
end
