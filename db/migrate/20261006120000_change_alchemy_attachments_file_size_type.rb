class ChangeAlchemyAttachmentsFileSizeType < ActiveRecord::Migration[7.0]
  def up
    change_column :alchemy_attachments, :file_size, :bigint
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
