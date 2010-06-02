class CreateWaFiles < ActiveRecord::Migration
  def self.up
    create_table :wa_files, :force => true do |t|
      t.column  :content_type,  :string
      t.column  :filename,      :string     
      t.column  :size,          :integer
      t.column  :parent_id,     :integer 
      t.column  :thumbnail,     :string
      t.column  :name,          :string
      t.column  :count,         :integer
    end
  end

  def self.down
    drop_table :wa_files
  end
end