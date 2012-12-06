module Alchemy
  class ElementsController < Alchemy::BaseController

    filter_access_to :show, :attribute_check => true, :model => Alchemy::Element, :load_method => :load_element
    layout false

    # Returns the element partial as HTML or as JavaScript that tries to replace a given +container_id+ with the partial content via jQuery.
    def show
      @page = @element.page
      respond_to do |format|
        format.html
        format.js
      end
    end

  private

    def load_element
      element = Element.available
      if !current_user
        element = element.not_restricted
      end
      @element = element.find(params[:id])
    end

  end
end
