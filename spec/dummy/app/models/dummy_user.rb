class DummyUser < ActiveRecord::Base
  attr_accessor :alchemy_roles, :name

  def self.logged_in
    []
  end

  def alchemy_roles
    @alchemy_roles || %w(admin)
  end
end
