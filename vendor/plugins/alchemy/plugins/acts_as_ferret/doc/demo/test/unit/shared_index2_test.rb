require File.dirname(__FILE__) + '/../test_helper'

class SharedIndex2Test < Test::Unit::TestCase
  fixtures :shared_index2s, :shared_index1s

  def setup
    SharedIndex1.rebuild_index
  end

  def test_query_for_record
    assert_match /SharedIndex2/, shared_index2s(:first).query_for_record.to_s
  end
end
