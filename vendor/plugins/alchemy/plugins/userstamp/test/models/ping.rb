class Ping < ActiveRecord::Base
  stampable :stamper_class_name => :person,
            :creator_attribute  => :creator_name,
            :updater_attribute  => :updater_name,
            :deleter_attribute  => :deleter_name
  belongs_to :post
end