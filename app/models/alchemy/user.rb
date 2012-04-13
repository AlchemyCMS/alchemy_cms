module Alchemy
  class User < ActiveRecord::Base

    model_stamper
    stampable
    acts_as_authentic do |c|
      c.transition_from_restful_authentication = true
      c.logged_in_timeout = Config.get(:auto_logout_time).minutes
    end

    attr_accessible(
      :firstname,
      :lastname,
      :login,
      :email,
      :gender,
      :role,
      :language,
      :password,
      :password_confirmation
    )

    has_many :folded_pages

    before_destroy :unlock_pages

    scope :admins, where(:role => 'admin')

    ROLES = Config.get(:user_roles)

    def role_symbols
      [role.to_sym]
    end

    def is_admin?
      true if self.role == "admin"
    end

    alias :admin? :is_admin?

    def unlock_pages
      for page in pages_locked_by_me
        page.unlock
      end
    end

    def pages_locked_by_me
      Page.where(:locked => true).where(:locked_by => self.id).order(:updated_at)
    end

    # Returns the firstname and lastname as a string
    # If both are blank, returns the login
    # options
    #   :flipped=false  : returns "lastname, firstname"
    def fullname(options = {})
      unless (self.lastname.blank? && self.firstname.blank?)
        options = (default_options = {:flipped => false}.merge(options))
        options[:flipped] ? "#{self.lastname}, #{self.firstname}".squeeze(" ") : "#{self.firstname} #{self.lastname}".squeeze(" ")
      else
        self.login
      end
    end

    alias :name :fullname

    def human_role_name
      self.class.human_rolename(self.role)
    end

    def self.human_rolename(role)
      I18n.t("user_roles.#{role}")
    end

    def self.genders_for_select
      [
        [I18n.t('male'), 'male'],
        [I18n.t('female'), 'female']
      ]
    end

  end
end
