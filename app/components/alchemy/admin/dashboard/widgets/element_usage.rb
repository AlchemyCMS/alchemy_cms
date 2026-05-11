module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class ElementUsage < ViewComponent::Base
          def initialize(style: "default")
            @style = style
          end

          private

          def stats = Alchemy::Element.published.group(:name).count.sort_by { |_, v| -v }
          def total = stats.sum { |_, v| v }
          def max = stats.map { |_, count| count }.max.to_f
        end
      end
    end
  end
end
