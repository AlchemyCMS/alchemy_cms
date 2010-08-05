require File.dirname(__FILE__) + '/../test_helper'

class RemoteIndexTest < Test::Unit::TestCase
  def setup
    ActsAsFerret::remote = 'druby://localhost:9999'
  end

  def test_raises_drb_errors
    ActsAsFerret::raise_drb_errors = true
    @srv = ActsAsFerret::RemoteIndex.new :name => 'idx'
    assert_raise DRb::DRbConnError do
      @srv.find_ids 'some query'
    end
  end

  def test_does_not_raise_drb_errors
    ActsAsFerret::raise_drb_errors = false
    @srv = ActsAsFerret::RemoteIndex.new :name => 'idx'
    total_hits, results = @srv.find_ids( 'some query' )
    assert_equal 0, total_hits
    assert results.empty?
  end
end
