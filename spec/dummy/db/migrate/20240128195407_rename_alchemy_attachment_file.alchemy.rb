# This migration comes from alchemy (originally 20240123080918)
class RenameAlchemyAttachmentFile < ActiveRecord::Migration[7.0]
  COLUMNS = %i[
    file_name
    file_size
    file_uid
  ]

  def change
    COLUMNS.each do |column|
      rename_column :alchemy_attachments, column, :"legacy_#{column}"
    end
  end
end
