module Alchemy
  module Admin
    class PageStatusIndicators < ViewComponent::Base
      def initialize(page:)
        @page = page
      end
    end
  end
end
