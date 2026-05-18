module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class StatWidget < ViewComponent::Base
          delegate :alchemy, to: :helpers

          private

          def title = raise(NotImplementedError)
          def count = raise(NotImplementedError)
          def icon = nil
          def link = nil
          def infos = nil
        end
      end
    end
  end
end
