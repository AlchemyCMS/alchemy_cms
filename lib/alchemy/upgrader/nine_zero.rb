# frozen_string_literal: true

require "alchemy/tasks/tidy"

module Alchemy
  class Upgrader
    module NineZero
      def remove_deprecated_columns
        connection = ActiveRecord::Base.connection
        deprecated_columns_exist = Alchemy::Tidy::DEPRECATED_COLUMNS.any? do |table, columns|
          columns.any? { connection.column_exists?(table, _1) }
        end
        return unless deprecated_columns_exist

        desc "Deprecated columns"
        if yes?("Remove the deprecated page metadata and element public columns now? (y/N)")
          Alchemy::Tidy.remove_deprecated_columns
        else
          todo <<~TODO, "Remove deprecated columns"
            `alchemy_pages.title`, `meta_description` and `meta_keywords` moved to
            page versions in Alchemy 8.1 and `alchemy_elements.public` was replaced
            by publication timestamps in 8.4. Alchemy ignores these columns.

            Remove them with:

                bin/rails alchemy:tidy:remove_deprecated_columns
          TODO
        end
      end
    end
  end
end
