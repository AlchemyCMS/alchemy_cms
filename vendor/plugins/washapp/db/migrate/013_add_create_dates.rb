class AddCreateDates < ActiveRecord::Migration
  def self.up
    add_column(:wa_pages, :created_at, :datetime)
    add_column(:wa_pages, :created_by, :integer)
    add_column(:wa_pages, :modified_at, :datetime)
    add_column(:wa_pages, :modified_by, :integer)
    WaPage.reset_column_information
    for page in WaPage.find(:all)
      page.created_at = Time.now
      page.created_by = 1
      page.modified_at = Time.now
      page.modified_by = 1
      page.save!
    end
  end

  def self.down
    remove_column(:wa_pages, :created_at)
    remove_column(:wa_pages, :created_by)
    remove_column(:wa_pages, :modified_at)
    remove_column(:wa_pages, :modified_by)
  end
end
