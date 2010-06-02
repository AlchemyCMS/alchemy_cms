$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'models/user'
require 'models/person'
require 'models/post'
require 'models/comment'

class StampingTests < Test::Unit::TestCase  # :nodoc:
  fixtures :users, :people, :posts, :comments

  def setup
    User.stamper = @zeus
    Person.stamper = @delynn
  end

  def test_person_creation_with_stamped_object
    assert_equal @zeus.id, User.stamper
    
    person = Person.create(:name => "David")
    assert_equal @zeus.id, person.creator_id
    assert_equal @zeus.id, person.updater_id
    assert_equal @zeus, person.creator
    assert_equal @zeus, person.updater
  end

  def test_person_creation_with_stamped_integer
    User.stamper = 2
    assert_equal 2, User.stamper

    person = Person.create(:name => "Daniel")
    assert_equal @hera.id, person.creator_id
    assert_equal @hera.id,  person.updater_id
    assert_equal @hera, person.creator
    assert_equal @hera, person.updater
  end

  def test_post_creation_with_stamped_object
    assert_equal @delynn.id, Person.stamper

    post = Post.create(:title => "Test Post - 1")
    assert_equal @delynn.id, post.creator_id
    assert_equal @delynn.id, post.updater_id
    assert_equal @delynn, post.creator
    assert_equal @delynn, post.updater
  end

  def test_post_creation_with_stamped_integer
    Person.stamper = 2
    assert_equal 2, Person.stamper

    post = Post.create(:title => "Test Post - 2")
    assert_equal @nicole.id, post.creator_id
    assert_equal @nicole.id, post.updater_id
    assert_equal @nicole, post.creator
    assert_equal @nicole, post.updater
  end

  def test_person_updating_with_stamped_object
    User.stamper = @hera
    assert_equal @hera.id, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus, @delynn.creator
    assert_equal @hera, @delynn.updater
    assert_equal @zeus.id, @delynn.creator_id
    assert_equal @hera.id, @delynn.updater_id
  end

  def test_person_updating_with_stamped_integer
    User.stamper = 2
    assert_equal 2, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus.id, @delynn.creator_id
    assert_equal @hera.id, @delynn.updater_id
    assert_equal @zeus, @delynn.creator
    assert_equal @hera, @delynn.updater
  end

  def test_post_updating_with_stamped_object
    Person.stamper = @nicole
    assert_equal @nicole.id, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.creator_id
    assert_equal @nicole.id, @first_post.updater_id
    assert_equal @delynn, @first_post.creator
    assert_equal @nicole, @first_post.updater
  end

  def test_post_updating_with_stamped_integer
    Person.stamper = 2
    assert_equal 2, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.creator_id
    assert_equal @nicole.id, @first_post.updater_id
    assert_equal @delynn, @first_post.creator
    assert_equal @nicole, @first_post.updater
  end
end