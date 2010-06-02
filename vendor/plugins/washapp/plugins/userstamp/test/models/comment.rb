class Comment < ActiveRecord::Base
  stampable   :stamper_class_name => :person
  belongs_to  :post
end