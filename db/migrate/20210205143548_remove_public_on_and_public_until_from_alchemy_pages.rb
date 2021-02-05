# frozen_string_literal: true

class RemovePublicOnAndPublicUntilFromAlchemyPages < ActiveRecord::Migration[6.0]
  def change
    remove_column :alchemy_pages, :public_on, :datetime
    remove_column :alchemy_pages, :public_until, :datetime
  end
end
