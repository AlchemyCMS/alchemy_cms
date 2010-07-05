require File.dirname(__FILE__) + '/../test_helper'

class SortTest < Test::Unit::TestCase
  include Ferret::Search

  def test_sort_marshalling
    [ Sort.new,
      Sort.new( [], :reverse => true) ,
      Sort.new([ Ferret::Search::SortField.new(:id, :reverse => true), 
                 Ferret::Search::SortField::SCORE,
                 Ferret::Search::SortField::DOC_ID ],
               :reverse => true),
      Sort.new([ Ferret::Search::SortField.new(:id), 
                 Ferret::Search::SortField::SCORE_REV,
                 Ferret::Search::SortField::DOC_ID_REV ])
    ].each do |sort|
      assert_equal sort.to_s, Sort._load(sort._dump(0)).to_s
    end 
  end

end
