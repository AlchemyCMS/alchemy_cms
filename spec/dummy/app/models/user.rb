class User
  extend  ::ActiveModel::Naming
  extend  ::ActiveModel::Translation
  include ::ActiveModel::Validations
  include ::ActiveModel::Conversion
  include ::ActiveModel::MassAssignmentSecurity
  attr_accessor :alchemy_roles, :email, :password

  alias_method :role_symbols, :alchemy_roles

  def self.logged_in
    []
  end
end
