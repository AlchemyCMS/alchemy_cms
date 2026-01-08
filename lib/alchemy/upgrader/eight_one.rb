# frozen_string_literal: true

module Alchemy
  class Upgrader
    module EightOne
      def migrate_page_metadata
        desc "Migrating page metadata to page versions"

        connection = ActiveRecord::Base.connection
        pages_table = Alchemy::Page.table_name
        versions_table = Alchemy::PageVersion.table_name

        unmigrated_count = connection.select_value(<<-SQL.strip_heredoc).to_i
          SELECT COUNT(*) FROM #{versions_table}
          WHERE title IS NULL
            AND meta_description IS NULL
            AND meta_keywords IS NULL
        SQL

        if unmigrated_count == 0
          log "All page versions have meta data.", :skip
          return
        end

        sql = if connection.adapter_name.downcase.match?(/mysql|trilogy/)
          <<-SQL.strip_heredoc
            UPDATE #{versions_table} pv
            INNER JOIN #{pages_table} p ON pv.page_id = p.id
            SET pv.title = p.title,
                pv.meta_description = p.meta_description,
                pv.meta_keywords = p.meta_keywords
            WHERE pv.title IS NULL
              AND pv.meta_description IS NULL
              AND pv.meta_keywords IS NULL
          SQL
        else
          <<-SQL.strip_heredoc
            UPDATE #{versions_table}
            SET title = p.title,
                meta_description = p.meta_description,
                meta_keywords = p.meta_keywords
            FROM #{pages_table} p
            WHERE #{versions_table}.page_id = p.id
              AND #{versions_table}.title IS NULL
              AND #{versions_table}.meta_description IS NULL
              AND #{versions_table}.meta_keywords IS NULL
          SQL
        end

        migrated_count = connection.update(sql)

        log "Migrated metadata for #{migrated_count} page versions."
      end
    end
  end
end
