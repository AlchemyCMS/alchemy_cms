class Content < ContentBase #ActiveRecord::Base

  def self.per_page; 10; end

  has_many :comments

  # returns the number of comments attached to this content.
  # the value returned by this method will be indexed, too.
  def comment_count
    comments.size
  end
end
