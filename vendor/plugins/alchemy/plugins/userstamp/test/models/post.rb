class Post < ActiveRecord::Base
  stampable :stamper_class_name => :person
  has_many :comments
end