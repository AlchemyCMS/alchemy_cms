require File.dirname(__FILE__) + '/../test_helper'
require 'contents_controller'

# Re-raise errors caught by the controller.
class ContentsController; def rescue_action(e) raise e end; end

class ContentsControllerTest < Test::Unit::TestCase
  fixtures :contents

  def setup
    @controller = ContentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contents)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:content)
    assert assigns(:content).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:content)
  end

  def test_create
    num_contents = Content.count

    post :create, :content => {}

    assert_response :redirect
    assert_redirected_to contents_url

    assert_equal num_contents + 1, Content.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:content)
    assert assigns(:content).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Content.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Content.find(1)
    }
  end

end
