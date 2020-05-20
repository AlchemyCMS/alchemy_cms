# frozen_string_literal: true

class AddLanguageIdForeignKeyToAlchemyPages < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :alchemy_pages, :alchemy_languages, column: :language_id
    change_column_null :alchemy_pages, :language_id, false, Alchemy::Language.default&.id
  end
end
