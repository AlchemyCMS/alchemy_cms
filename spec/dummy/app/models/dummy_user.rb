class DummyUser < ActiveRecord::Base
  attr_accessor :alchemy_roles, :name

  def self.logged_in
    []
  end
end
