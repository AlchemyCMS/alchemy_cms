module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class PageUsage < ViewComponent::Base
          private

          def stats = Alchemy::Page.group(:page_layout).count.sort_by { |_, v| -v }
          def total = stats.sum { |_, v| v }
          def max = stats.map { |_, count| count }.max.to_f
        end
      end
    end
  end
end
