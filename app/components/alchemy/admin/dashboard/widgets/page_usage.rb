module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class PageUsage < UsageWidget
          private

          def header_text(total:)
            Alchemy.t(:page_usage, total:)
          end

          def definitions
            Alchemy::PageDefinition.all
          end

          def public_counts
            @public_counts ||= Alchemy::Page.published.group(:page_layout).count
          end

          def draft_counts
            @draft_counts ||= Alchemy::Page
              .where.not(id: Alchemy::Page.published.select(:id))
              .where.not(id: Alchemy::PageVersion.where("public_on > ?", Time.current).select(:page_id))
              .group(:page_layout).count
          end

          def entry_label(entry)
            entry.definition.human_name
          end

          def entry_icon(entry)
            helpers.content_tag(:"alchemy-icon", "", name: "file")
          end
        end
      end
    end
  end
end
