class User
  include ActiveModel::Model
  attr_accessor :alchemy_roles, :email, :password

  def self.logged_in
    []
  end
end
