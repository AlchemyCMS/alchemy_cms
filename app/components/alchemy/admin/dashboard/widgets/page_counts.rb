module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class PageCounts < StatWidget
          def initialize(style:)
            @style = style
          end

          private

          def link = alchemy.admin_pages_path
          def icon = "pages"
          def title = Alchemy::Page.model_name.human(count: :many)
          def count = Alchemy::Page.count

          def infos
            safe_join([
              number_with_delimiter(Alchemy::Page.published.count),
              t(".published")
            ], " ")
          end
        end
      end
    end
  end
end
