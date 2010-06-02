require File.dirname(__FILE__) + '/../test_helper'

class WaPagesControllerTest < ActionController::TestCase
  def test_that_current_page_is_set
    assert(current_page = assigns(:current_page), "Cannot find @wa_page")
  end
end

# require 'test_helper'
# 
# class WaPagesControllerTest < ActionController::TestCase
#   # Replace this with your real tests.
#   def test_truth
#     assert true
#   end
# end
