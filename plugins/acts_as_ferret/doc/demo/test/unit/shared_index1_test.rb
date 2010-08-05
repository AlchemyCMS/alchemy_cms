require File.dirname(__FILE__) + '/../test_helper'

class SharedIndex1Test < Test::Unit::TestCase
  fixtures :shared_index1s, :shared_index2s

  def setup
    SharedIndex1.rebuild_index
  end

  def test_lazy_loading
    results = ActsAsFerret::find 'first', 'shared', :lazy => [ :name ]
    assert_equal 2, results.size
    found_lazy_result = false
    results.each { |r|
      assert ActsAsFerret::FerretResult === r
      assert !r.name.blank?
      assert_nil r.instance_variable_get(:@ar_record) # lazy, AR record has not been fetched
    }
  end
  
  def test_find
    assert_equal shared_index1s(:first), SharedIndex1.find(1)
    assert_equal shared_index2s(:first), SharedIndex2.find(1)
  end

  def test_find_ids_with_ferret
    result = SharedIndex1.find_ids_with_ferret("first")
    assert_equal 2, result.size
  end

  def test_find_with_ferret_one_class
    result = SharedIndex1.find_with_ferret("first")
    assert_equal 1, result.size, result.inspect
    assert_equal shared_index1s(:first), result.first
  end

  def test_custom_query
    result = SharedIndex1.find_with_ferret("name:first class_name:SharedIndex1")
    assert_equal 1, result.size
    assert_equal shared_index1s(:first), result.first
  end

  def test_find_with_index_name
    result = ActsAsFerret::find("first", 'shared')
    assert_equal 2, result.size
    assert result.include?(shared_index1s(:first))
    assert result.include?(shared_index2s(:first))
  end

  def test_find_with_class_list
    result = ActsAsFerret::find("name:first", [SharedIndex1, SharedIndex2])
    assert_equal 2, result.size
    assert result.include?(shared_index1s(:first))
    assert result.include?(shared_index2s(:first))
  end

  def test_query_for_record
    assert_match /SharedIndex1/, shared_index1s(:first).query_for_record.to_s
  end

  def test_destroy
    result = ActsAsFerret::find("first OR another", 'shared')
    assert_equal 4, result.size
    SharedIndex1.destroy(shared_index1s(:first))
    result = ActsAsFerret::find("first OR another", 'shared')
    assert_equal 3, result.size
    shared_index2s(:first).destroy
    result = ActsAsFerret::find("first OR another", 'shared')
    assert_equal 2, result.size
  end

  def test_ferret_destroy
    SharedIndex1.rebuild_index
    result = SharedIndex1.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 4, result.first
    shared_index1s(:first).ferret_destroy
    result = SharedIndex1.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 3, result.first
  end

  def test_ferret_destroy_ticket_88
    SharedIndex1.rebuild_index
    result = SharedIndex1.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 4, result.first
    result = SharedIndex2.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 4, result.first
    SharedIndex1.destroy(shared_index1s(:first))
    result = SharedIndex1.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 3, result.first
    result = SharedIndex2.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 3, result.first
    shared_index2s(:first).destroy
    result = SharedIndex1.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 2, result.first
    result = SharedIndex2.find_ids_with_ferret("first OR another", :models => :all)
    assert_equal 2, result.first
  end

  def test_update
    assert SharedIndex1.find_with_ferret("new").empty?
    shared_index1s(:first).name = "new name"
    shared_index1s(:first).save
    assert_equal 1, SharedIndex1.find_with_ferret("new").size
    assert_equal 1, SharedIndex1.find_with_ferret("new").size
    assert_equal 1, SharedIndex1.find_with_ferret("new", :models => [SharedIndex2]).size
    assert_equal 0, SharedIndex2.find_with_ferret("new").size
  end
end
