require File.dirname(__FILE__) + '/../test_helper'
require 'searches_controller'

# Re-raise errors caught by the controller.
class SearchesController; def rescue_action(e) raise e end; end

class SearchesControllerTest < Test::Unit::TestCase
  fixtures :contents

  def setup
    @controller = SearchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ContentBase.rebuild_index
  end

  def test_search
    get :search
    assert_template 'search'
    assert_response :success
    assert_nil assigns(:results)
  end

  def test_search
    get :search, :q => 'title'
    assert_template 'search'
    assert_equal 1, assigns(:results).total_hits
    assert_equal 1, assigns(:results).size
    
    get :search, :q => 'monkey'
    assert_template 'search'
    assert assigns(:results).empty?
    
    # check that model changes are picked up by the searcher (searchers have to
    # be reopened to reflect changes done to the index)
    # wait for the searcher to age a bit (it seems fs timestamp resolution is
    # only 1 sec)
    sleep 1
    Content.create :title => 'another content object', :description => 'description goes hers'
    get :search, :q => 'another'
    assert_template 'search'
    assert_equal 1, assigns(:results).total_hits
    assert_equal 1, assigns(:results).size
    
  end

  def test_pagination
    Content.destroy_all
    30.times do |i|
      Content.create! :title => "title of Content #{i}", :description => "#{i}"
    end
    get :search, :q => 'title'
    r = assigns(:results)
    assert_equal 30, r.total_hits
    assert_equal 10, r.size
    assert_equal "title of Content 0", r.first.title
    assert_equal "title of Content 9", r.last.title
    assert_equal 1, r.current_page
    assert_equal 3, r.page_count

    get :search, :q => 'title', :page => 2
    r = assigns(:results)
    assert_equal 30, r.total_hits
    assert_equal 10, r.size
    assert_equal "title of Content 10", r.first.title
    assert_equal "title of Content 19", r.last.title
    assert_equal 2, r.current_page
    assert_equal 3, r.page_count
  end

end
