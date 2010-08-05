require File.dirname(__FILE__) + '/../test_helper'
require 'pp'
require 'fileutils'

class FerretResultTest < Test::Unit::TestCase
  fixtures :contents

  def teardown
  end
  
  def test_get_prefetched_fields_from_hash
    fr = ActsAsFerret::FerretResult.new 'Content', '1', 0.5, 1, :description => 'description from ferret index'
    assert_equal 'description from ferret index', fr.description
    assert_equal 0.5, fr.ferret_score
    assert_equal 1, fr.ferret_rank
    assert_equal 'My Title', fr.title # triggers auto-load of the record
    assert_equal 'A useless description', fr.description # description now comes from DB
  end

  def test_to_param
    fr = ActsAsFerret::FerretResult.new 'Content', '1', 0.5, 1, :description => 'description from ferret index'
    assert_equal '1', fr.to_param
  end
end
