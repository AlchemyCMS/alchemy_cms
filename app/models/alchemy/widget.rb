module Alchemy
  class Widget < Apotomo::Widget
    helper Alchemy::Admin::BaseHelper, Alchemy::Admin::FormHelper
    after_initialize :setup!

  private
    def setup!(options)
      @current_alchemy_user = @options[:current_alchemy_user]
      @widget = self
    end
  end
end
