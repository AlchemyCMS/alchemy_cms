module Tableless
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include,InstanceMethods)
  end
  
  module InstanceMethods
    def save(validate = true)
      validate ? valid? : true
    end
  end
  
  module ClassMethods
    def column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
        sql_type.to_s, null)
    end
    
    def columns
      @columns ||= [];
    end
  end
end