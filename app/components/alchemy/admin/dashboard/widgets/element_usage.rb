module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class ElementUsage < ViewComponent::Base
          private

          def stats = Alchemy::Element.published.group(:name).count.sort_by { |_, v| -v }
          def total = stats.sum { |_, v| v }
          def max = stats.map { |_, count| count }.max.to_f
        end
      end
    end
  end
end
