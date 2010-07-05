class InitialMigration < ActiveRecord::Migration
  def self.up
    create_table "comments" do |t|
      t.column "author", :string, :limit => 100
      t.column "content", :text
      t.column "content_id", :integer
    end
    create_table "contents" do |t|
      t.column "title", :string, :limit => 100
      t.column "description", :text
    end
  end

  def self.down
    drop_table "comments"
    drop_table "contents"
  end
end
