$:.unshift(File.dirname(__FILE__))

require 'helpers/functional_test_helper'
require 'controllers/userstamp_controller'
require 'controllers/users_controller'
require 'controllers/posts_controller'
require 'models/user'
require 'models/person'
require 'models/post'
require 'models/comment'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class PostsControllerTest < Test::Unit::TestCase
  fixtures :users, :people, :posts, :comments

  def setup
    @controller   = PostsController.new
    @request      = ActionController::TestRequest.new
    @response     = ActionController::TestResponse.new
  end

  def test_update_post
    @request.session  = {:person_id => 1}
    post :update, :id => 1, :post => {:title => 'Different'}
    assert_response :success
    assert_equal    'Different', assigns["post"].title
    assert_equal    @delynn, assigns["post"].updater
  end

  def test_update_with_multiple_requests
    @request.session    = {:person_id => 1}
    get :edit, :id => 2
    assert_response :success

    simulate_second_request    

    post :update, :id => 2, :post => {:title => 'Different'}
    assert_response :success
    assert_equal    'Different', assigns["post"].title
    assert_equal    @delynn, assigns["post"].updater
  end
  
  def simulate_second_request
    @second_controller  = PostsController.new
    @second_request     = ActionController::TestRequest.new
    @second_response    = ActionController::TestResponse.new
    @second_response.session = {:person_id => 2}

    @second_request.env['REQUEST_METHOD'] = "POST"
    @second_request.action = 'update'

    parameters = {:id => 1, :post => {:title => 'Different Second'}}
    @second_request.assign_parameters(@second_controller.class.controller_path, 'update', parameters)
    @second_request.session = ActionController::TestSession.new(@second_response.session)
    
    options = @second_controller.send!(:rewrite_options, parameters)
    options.update(:only_path => true, :action => 'update')
    
    url = ActionController::UrlRewriter.new(@second_request, parameters)
    @second_request.set_REQUEST_URI(url.rewrite(options))
    @second_controller.process(@second_request, @second_response)
    
    assert_equal    @nicole, @second_response.template.instance_variable_get("@post").updater
  end
end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users, :people, :posts, :comments

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_update_user
    @request.session  = {:user_id => 2}
    post :update, :id => 2, :user => {:name => 'Different'}
    assert_response :success
    assert_equal    'Different', assigns["user"].name
    assert_equal    @hera, assigns["user"].updater
  end
  
  def test_update_with_multiple_requests
    @request.session  = {:user_id => 2}
    get :edit, :id =>  2
    assert_response :success
    
    simulate_second_request
  end

  def simulate_second_request
    @second_controller  = UsersController.new
    @second_request     = ActionController::TestRequest.new
    @second_response    = ActionController::TestResponse.new
    @second_response.session = {:user_id => 1}

    @second_request.env['REQUEST_METHOD'] = "POST"
    @second_request.action = 'update'

    parameters = {:id => 2, :user => {:name => 'Different Second'}}
    @second_request.assign_parameters(@second_controller.class.controller_path, 'update', parameters)
    
    @second_request.session = ActionController::TestSession.new(@second_response.session)
    
    options = @second_controller.send!(:rewrite_options, parameters)
    options.update(:only_path => true, :action => 'update')
    
    url = ActionController::UrlRewriter.new(@second_request, parameters)
    @second_request.set_REQUEST_URI(url.rewrite(options))
    @second_controller.process(@second_request, @second_response)
    
    assert_equal    @zeus, @second_response.template.instance_variable_get("@user").updater
  end
end