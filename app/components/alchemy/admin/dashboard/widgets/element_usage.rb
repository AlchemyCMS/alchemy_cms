module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class ElementUsage < UsageWidget
          private

          def header_text(total:)
            Alchemy.t(:element_usage, total:)
          end

          def definitions
            Alchemy::ElementDefinition.all
          end

          def public_counts
            @public_counts ||= Alchemy::Element.published.group(:name).count
          end

          def draft_counts
            @draft_counts ||= Alchemy::Element
              .where("alchemy_elements.public_on IS NULL OR alchemy_elements.public_until <= ?", Time.current)
              .group(:name).count
          end

          def entry_label(entry)
            Alchemy::Element.display_name_for(entry.name)
          end

          def entry_icon(entry)
            entry.definition.icon_file
          end
        end
      end
    end
  end
end
