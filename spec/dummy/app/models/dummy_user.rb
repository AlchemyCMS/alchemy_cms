class DummyUser
  include ActiveModel::Validations

  attr_accessor :alchemy_roles, :language, :cache_key, :email, :password, :name, :id

  def self.logged_in
    []
  end

  def self.stamper_class_name
    :DummyUser
  end

  def update_attributes(attributes)
    attributes.each { |key,value| send("#{key}=".to_sym, value) }
  end
end
