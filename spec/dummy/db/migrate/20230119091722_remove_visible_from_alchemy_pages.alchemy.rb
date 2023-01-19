# frozen_string_literal: true
# This migration comes from alchemy (originally 20200519073500)
class RemoveVisibleFromAlchemyPages < ActiveRecord::Migration[6.0]
  class LocalPage < ActiveRecord::Base
    self.table_name = "alchemy_pages"

    scope :invisible, -> { where(visible: [false, nil]) }
    scope :contentpages, -> { where(layoutpage: [false, nil]) }
  end

  def up
    if LocalPage.invisible.contentpages.where.not(parent_id: nil).any?
      abort "You have invisible pages in your database! " \
            "Please re-structure your page tree before running this migration. " \
            "You might also downgrade to Alchemy 4.6 and " \
            "run the `alchemy:upgrade:4.6:restructure_page_tree` rake task."
    end

    remove_column :alchemy_pages, :visible
  end

  def down
    add_column :alchemy_pages, :visible, :boolean, default: false
  end
end
