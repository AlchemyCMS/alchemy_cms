class AddCreateDates < ActiveRecord::Migration
  def self.up
    add_column(:pages, :created_at, :datetime)
    add_column(:pages, :created_by, :integer)
    add_column(:pages, :modified_at, :datetime)
    add_column(:pages, :modified_by, :integer)
    Page.reset_column_information
    for page in Page.find(:all)
      page.created_at = Time.now
      page.created_by = 1
      page.modified_at = Time.now
      page.modified_by = 1
      page.save!
    end
  end

  def self.down
    remove_column(:pages, :created_at)
    remove_column(:pages, :created_by)
    remove_column(:pages, :modified_at)
    remove_column(:pages, :modified_by)
  end
end
