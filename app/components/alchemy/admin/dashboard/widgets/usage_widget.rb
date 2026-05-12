module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class UsageWidget < ViewComponent::Base
          Entry = Data.define(:name, :public_count, :draft_count, :definition) do
            def total = public_count + draft_count
          end

          private

          def stats
            @stats ||= definitions
              .map do |definition|
                Entry.new(
                  name: definition.name,
                  public_count: public_counts.fetch(definition.name, 0),
                  draft_count: draft_counts.fetch(definition.name, 0),
                  definition: definition
                )
              end
              .sort_by { |entry| -entry.total }
          end

          def total
            @total ||= stats.sum(&:total)
          end

          def max
            @max ||= (stats.first&.total || 0).to_f
          end

          # Subclass hooks

          def header_text(total:)
            raise NotImplementedError
          end

          def definitions
            raise NotImplementedError
          end

          def public_counts
            raise NotImplementedError
          end

          def draft_counts
            raise NotImplementedError
          end

          def entry_label(entry)
            raise NotImplementedError
          end

          def entry_icon(entry)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
