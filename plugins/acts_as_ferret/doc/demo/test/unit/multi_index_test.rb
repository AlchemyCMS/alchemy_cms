require File.dirname(__FILE__) + '/../test_helper'
require 'pp'
require 'fileutils'

class MultiIndexTest < Test::Unit::TestCase
  include Ferret::Index
  include Ferret::Search
  fixtures :contents, :comments

  def setup
    #make sure the fixtures are in the index
    FileUtils.rm_f 'index/test/'
    Comment.rebuild_index
    ContentBase.rebuild_index 
    raise "missing fixtures" unless ContentBase.count > 2
    
    @another_content = Content.new( :title => 'Another Content item', 
                                    :description => 'this is not the title' )
    @another_content.save
    @comment = @another_content.comments.create(:author => 'john doe', :content => 'This is a useless comment')
    @comment2 = @another_content.comments.create(:author => 'another', :content => 'content')
    @another_content.save # to update comment_count in ferret-index
  end
  
  def teardown
    ContentBase.find(:all).each { |c| c.destroy }
    Comment.find(:all).each { |c| c.destroy }
  end


  # weiter: single index / multisearch lazy loading
#  def test_lazy_loading
#    results = Content.find_with_ferret 'description', :lazy => true
#    assert_equal 1, results.size
#    result = results.first
#    class << result
#      attr_accessor :ar_record # so we have a chance to check if it's been loaded...
#    end
#    assert ActsAsFerret::FerretResult === result
#    assert_equal 'A useless description', result.description
#    assert_nil result.instance_variable_get(:@ar_record)
#    assert_equal 'My Title', result.title
#    assert_not_nil result.ar_record
#  end

  
  def test_total_hits
    q = '*:title OR *:comment'
    assert_equal 3, Comment.total_hits(q)
    assert_equal 2, Content.total_hits(q)
    assert_equal 5, ActsAsFerret::total_hits(q, [ Comment, Content ])
  end

  def test_sorting
    sorting = [ Ferret::Search::SortField.new(:id) ]
    result = ActsAsFerret::find('*:title OR *:comment', [Content, Comment], :sort => sorting)
    assert_equal result.map(&:id).sort, result.map(&:id)

    sorting = [ Ferret::Search::SortField.new(:title) ]
    result = ActsAsFerret::find('*:title OR *:comment', [Content, Comment], :sort => sorting)
    sorting = [ Ferret::Search::SortField.new(:title, :reverse => true) ]
    result2 = ActsAsFerret::find('*:title OR *:comment', [Content, Comment], :sort => sorting)
    assert result.any?
    assert result.map(&:id) != result2.map(&:id)

    result = ActsAsFerret::find('*:title OR *:comment', [Content, Comment ])
    assert result.any?
    assert_equal result.map(&:ferret_score).sort.reverse, result.map(&:ferret_score)

    sorting = [ Ferret::Search::SortField::SCORE ]
    result = ActsAsFerret::find('*:title OR *:comment', [Content, Comment ], :sort => sorting)
    assert result.any?
    assert_equal result.map(&:ferret_score).sort.reverse, result.map(&:ferret_score)

    sorting = [ Ferret::Search::SortField::SCORE_REV ]
    result2 = ActsAsFerret::find('*:title OR *:comment', [Content, Comment], :sort => sorting)
    assert_equal result2.map(&:ferret_score).sort, result2.map(&:ferret_score)
    assert_equal result.map(&:ferret_score), result2.map(&:ferret_score).reverse
  end

  
  # remote index rebuilds will create an index in a directory with a timestamped name.
  # the local MultiIndex instance doesn't know about this (because it's running in 
  # another interpreter instance than the server) and therefore fails to use the 
  # correct index directories.
  # TODO strange, still doesn't work but it should now...
  unless Content.aaf_configuration[:remote]
    def test_multi_index
      i =  ActsAsFerret::get_index_for Content, Comment
      assert ActsAsFerret::MultiIndex === i
      hits = i.search(TermQuery.new(:title,"title"))
      assert_equal 1, hits.total_hits

      qp = Ferret::QueryParser.new(:default_field => "title", 
                                  :analyzer => Ferret::Analysis::WhiteSpaceAnalyzer.new)
      hits = i.search(qp.parse("title"))
      assert_equal 1, hits.total_hits
      
      qp = Ferret::QueryParser.new(:fields => ['title', 'content', 'description'],
                        :analyzer => Ferret::Analysis::WhiteSpaceAnalyzer.new)
      hits = i.search(qp.parse("title"))
      assert_equal 2, hits.total_hits
      hits = i.search(qp.parse("title:title OR description:title"))
      assert_equal 2, hits.total_hits

      hits = i.search("title:title OR description:title OR title:comment OR description:comment OR content:comment")
      assert_equal 5, hits.total_hits

      hits = i.search("title OR comment")
      assert_equal 5, hits.total_hits

      hits = i.search("title OR comment", :limit => 2)
      count = 0
      hits.hits.each { |hit, score| count += 1 }
      assert_equal 2, count

      hits = i.search("title OR comment", :offset => 2)
      count = 0
      hits.hits.each { |hit, score| count += 1 }
      assert_equal 3, count
    end
  end

  def test_search_rebuilds_index
    remove_index Content
    contents_from_ferret = ActsAsFerret::find('description:title', [Content, Comment])
    assert_equal 1, contents_from_ferret.size
  end

  # remote index rebuilds will create an index in a directory with a timestamped name...
  unless Content.aaf_configuration[:remote]
    def test_rebuilds_index
      remove_index Content
      idx = ActsAsFerret.get_index_for( Content )
      i =  ActsAsFerret::MultiIndex.new([idx])
      assert File.exists?("#{idx.index_definition[:index_dir]}/segments")
      hits = i.search("description:title")
      assert_equal 1, hits.total_hits, hits.inspect
    end
  end

  def test_find_options
    contents_from_ferret = ActsAsFerret::find('title', [Content, Comment ], { }, :order => 'id desc')
    assert_equal 2, contents_from_ferret.size
    assert contents_from_ferret.first.id > contents_from_ferret.last.id
    contents_from_ferret = ActsAsFerret::find('title', [Content, Comment ], { }, :order => 'id asc')
    assert contents_from_ferret.first.id < contents_from_ferret.last.id

    contents_from_ferret = ActsAsFerret::find('title', [Content, Comment], :limit => 1)
    assert_equal 1, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title', [Content, Comment ], { }, :limit => 1)
    assert_equal 1, contents_from_ferret.size


    more_contents(true)
    r = ActsAsFerret::find('title OR comment', [Content, Comment], { :limit => :all } )
    assert_equal 60, r.size
    assert_equal 60, r.total_hits

    id = Content.find_with_ferret('title').first.id
    r = ActsAsFerret::find('title OR comment', [Content, Comment], { :limit => :all },
                                                     { :conditions => { :content => ["id != ?", id] }})
    assert_equal 59, r.size
    assert_equal 59, r.total_hits

    r = ActsAsFerret::find('title OR comment', [Content, Comment], { :limit => 20 },
                                                     { :conditions => { :content => ["id != ?", id] }})
    assert_equal 20, r.size
    assert_equal 59, r.total_hits

    r = ActsAsFerret::find('title OR comment', [Content, Comment], { :limit => 20 },
                                                     { :conditions => { :comment => 'content is null',
                                                                        :content => ["id != ?", id] }})
    assert_equal 20, r.size
    assert_equal 29, r.total_hits

    r = ActsAsFerret::find('title OR comment', [Content, Comment ], { },
                                                     { :conditions => { :content => ["id != ?", id] }, :limit => 20 })
    assert_equal 20, r.size
    assert_equal 59, r.total_hits
  end

  def test_multi_search
    assert_equal 4, ContentBase.find(:all).size
    
    Content.aaf_index.ferret_index.flush
    contents_from_ferret = ActsAsFerret::find('description:title', [Content])
    assert_equal 1, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title:title OR description:title', [Content])
    assert_equal 2, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title:title', [Content])
    assert_equal 1, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('*:title', [Content])
    assert_equal 2, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title', [Content])
    assert_equal 2, contents_from_ferret.size
    
    assert_equal contents(:first).id, contents_from_ferret.first.id
    assert_equal @another_content.id, contents_from_ferret.last.id
    
    contents_from_ferret = ActsAsFerret::find('title', [Content])
    assert_equal 2, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title', [Content], :limit => 1)
    assert_equal 1, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title', [Content], :offset => 1)
    assert_equal 1, contents_from_ferret.size

    contents_from_ferret = ActsAsFerret::find('title:title OR content:comment OR description:title', [Content, Comment])
    assert_equal 5, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title:title OR content:comment OR description:title', [Content, Comment], :limit => 2)
    assert_equal 2, contents_from_ferret.size

    contents_from_ferret = ActsAsFerret::find('*:title OR *:comment', [Content, Comment])
    assert_equal 5, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('*:title OR *:comment', [Content, Comment])
    assert_equal 5, contents_from_ferret.size
    contents_from_ferret = ActsAsFerret::find('title:(title OR comment) OR description:(title OR comment) OR content:(title OR comment)', [Content, Comment])
    assert_equal 5, contents_from_ferret.size
  end

  def test_lazy_search
    contents_from_ferret = ActsAsFerret.find('title', [Content, Comment], :lazy => true)
    assert_equal 2, contents_from_ferret.size
    contents_from_ferret.each do |record|
      assert ActsAsFerret::FerretResult === record, record.inspect
      assert !record.description.blank?
      assert_nil record.instance_variable_get(:"@ar_record")
    end
  end

  def test_find_ids
    assert_equal 4, ContentBase.find(:all).size
    
    [ 'title:title OR description:title OR content:title', 'title', '*:title'].each do |query|
      total_hits, contents_from_ferret = ActsAsFerret.find_ids(query, Content)
      assert_equal 2, contents_from_ferret.size, query
      assert_equal 2, total_hits, query
      assert_equal contents(:first).id, contents_from_ferret.first[:id].to_i
      assert_equal @another_content.id, contents_from_ferret.last[:id].to_i
    end

    ContentBase.rebuild_index
    Comment.rebuild_index
    ['title OR comment', 'title:(title OR comment) OR description:(title OR comment) OR content:(title OR comment)'].each do |query|
      total_hits, contents_from_ferret = ActsAsFerret.find_ids(query, [Comment, Content])
      assert_equal 5, contents_from_ferret.size, query
      assert_equal 5, total_hits
    end
  end

  def test_find_ids_lazy
    total_hits, contents_from_ferret = ActsAsFerret.find_ids('title', [Comment, Content], :lazy => true)
    assert_equal 2, contents_from_ferret.size
    assert_equal 2, total_hits
    found = 0
    contents_from_ferret.each do |data|
      next if data[:model] != 'Content'
      found += 1
      assert !data[:data][:description].blank?
    end
    assert_equal 2, found
  end

  def test_pagination
    more_contents(true)

    r = ActsAsFerret.find 'title OR comment', [ Content, Comment ], :per_page => 10, :sort => 'title'
    assert_equal 60, r.total_hits
    assert_equal 10, r.size
    assert_equal "0", r.first.description
    assert_equal "9", r.last.description
    assert_equal 1, r.current_page
    assert_equal 6, r.page_count

    r = ActsAsFerret.find 'title OR comment', [ Content, Comment ], :page => '2', :per_page => 10, :sort => 'title'
    assert_equal 60, r.total_hits
    assert_equal 10, r.size
    assert_equal "10", r.first.description
    assert_equal "19", r.last.description
    assert_equal 2, r.current_page
    assert_equal 6, r.page_count

    r = ActsAsFerret.find 'title OR comment', [ Content, Comment ], :page => 7, :per_page => 10, :sort => 'title'
    assert_equal 60, r.total_hits
    assert_equal 0, r.size
  end

  def test_pagination_with_ar_conditions
    more_contents(true)
    id = Content.find_with_ferret('title').first.id
    r = ActsAsFerret.find 'title OR comment', [Content, Comment], { :page => 1, :per_page => 10 }, 
                                          { :conditions => { :content => ["id != ?", id] }, :order => 'id ASC' }
    assert_equal 59, r.total_hits
    assert_equal 10, r.size
    assert_equal "Comment for content 00", r.first.content
    assert_equal "Comment for content 09", r.last.content
    assert_equal 1, r.current_page
    assert_equal 6, r.page_count

    r = ActsAsFerret.find 'title OR comment', [Content, Comment], { :page => 6, :per_page => 10 },
                                          { :conditions => { :content => [ "id != ?", id ] }, :order => 'id ASC' }
    assert_equal 59, r.total_hits
    assert_equal 9, r.size
    assert_equal "21", r.first.description
    assert_equal "29", r.last.description
    assert_equal 6, r.current_page
    assert_equal 6, r.page_count
  end

  protected

  def more_contents(with_comments = false)
    Comment.destroy_all if with_comments
    Content.destroy_all
    SpecialContent.destroy_all
    30.times do |i|
      c = Content.create! :title => sprintf("title of Content %02d", i), :description => "#{i}"
      c.comments.create! :content => sprintf("Comment for content %02d", i) if with_comments
    end
  end

  def remove_index(clazz)
    clazz.aaf_index.close # avoid io error when deleting the open index
    FileUtils.rm_rf clazz.aaf_configuration[:index_dir]
    assert !File.exists?("#{clazz.aaf_configuration[:index_dir]}/segments")
  end

end

