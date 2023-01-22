# frozen_string_literal: true

# This migration comes from alchemy (originally 20200505215518)
class AddLanguageIdForeignKeyToAlchemyPages < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :alchemy_pages, :alchemy_languages, column: :language_id
    change_column_null :alchemy_pages, :language_id, false, Alchemy::Language.default&.id
  end
end
