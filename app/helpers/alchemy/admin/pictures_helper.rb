# frozen_string_literal: true

module Alchemy
  module Admin
    module PicturesHelper
      def preview_size(size)
        case size
        when 'small' then '80x60'
        when 'large' then '240x180'
        else
          '160x120'
        end
      end
    end
  end
end
