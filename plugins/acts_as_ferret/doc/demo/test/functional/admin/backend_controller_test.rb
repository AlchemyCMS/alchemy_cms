require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/backend_controller'

# Re-raise errors caught by the controller.
class Admin::BackendController; def rescue_action(e) raise e end; end

class Admin::BackendControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::BackendController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Content.destroy_all
    Content.create(:title => 'my title', :description => 'a little bit of content')
  end

  def teardown
    Content.destroy_all
  end

  def test_search
    get :search
    assert_response :success
    assert_template 'search'
    assert_nil assigns(:results)

    post :search, :query => 'title'
    assert_template 'search'
    assert_equal 1, assigns(:results).size
    
    post :search, :query => 'monkey'
    assert_template 'search'
    assert assigns(:results).empty?
 
  end
end
