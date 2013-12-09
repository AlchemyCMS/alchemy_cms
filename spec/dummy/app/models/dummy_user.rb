class DummyUser < ActiveRecord::Base
  attr_accessor :alchemy_roles

  def self.logged_in
    []
  end
end
