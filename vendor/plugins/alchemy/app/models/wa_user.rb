class WaUser < ActiveRecord::Base
  
  model_stamper
  stampable :stamper_class_name => :wa_user
  acts_as_authentic do |c|
    c.transition_from_restful_authentication = true
    if Rails.env == 'production'
      c.logged_in_timeout = 15.minutes
    end
  end
  
  has_many :wa_foldeds
  
  after_destroy :unlock_pages
  
  ROLES = WaConfigure.parameter(:user_roles)#%w[registered author editor admin]
  
  def role_symbols
    [role.to_sym]
  end
  
  def is_admin?
    true if self.role == "admin"
  end
  alias :admin? :is_admin?
  
  def unlock_pages
    for page in WaPage.find(:all, :conditions => {:locked_by => self.id})
      page.unlock
    end
  end
  
  # returns the firstname and lastname as a string
  #if both are blank, returns the login
  # options
  #   :flipped=false  #returns lastname, firstname
  def fullname options = {}
    unless(self.lastname.blank? && self.firstname.blank?)
      options = (default_options = { :flipped => false }.merge(options))
      options[:flipped] ? "#{self.lastname}, #{self.firstname}".squeeze(" ") : "#{self.firstname} #{self.lastname}".squeeze(" ")
    else
      ""
    end
  end
  
  def name
    return login if fullname.blank?
    fullname
  end
  
  def self.human_rolename(role)
    I18n.t("user_roles.#{role}")
  end
  
  def self.genders_for_select
    [
      [_('male'), 'male'],
      [_('female'), 'female']
    ]
  end
  
end
