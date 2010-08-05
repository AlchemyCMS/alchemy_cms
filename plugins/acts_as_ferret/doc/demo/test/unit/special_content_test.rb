require File.dirname(__FILE__) + '/../test_helper'

class SpecialContentTest < Test::Unit::TestCase
  include Ferret::Index
  include Ferret::Search
  fixtures :contents, :comments

  def setup
    ContentBase.rebuild_index
    Comment.rebuild_index
  end
  
  def test_class_index_dir
    assert SpecialContent.aaf_configuration[:index_dir] =~ %r{^#{RAILS_ROOT}/index/test/content_base}
  end

  def test_find_with_ferret
    contents_from_ferret = SpecialContent.find_with_ferret('single table')
    assert_equal 1, contents_from_ferret.size
    assert_equal ContentBase.find(3), contents_from_ferret.first
    contents_from_ferret = SpecialContent.find_with_ferret('title')
    assert contents_from_ferret.empty?
    
  end
end
