module Alchemy
  module Admin
    class StyleguideController < BaseController
      authorize_resource class: :alchemy_admin_styleguide
    end
  end
end
