module Alchemy
	class User < ActiveRecord::Base

		model_stamper
		stampable
		acts_as_authentic do |c|
			c.transition_from_restful_authentication = true
			c.logged_in_timeout = Alchemy::Config.get(:auto_logout_time).minutes
		end
		
		has_many :folded_pages
		
		before_destroy :unlock_pages
		
		scope :admins, where(:role => 'admin')
		
		ROLES = Alchemy::Config.get(:user_roles)
		
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
			unless(self.lastname.blank? && self.firstname.blank?)
				options = (default_options = { :flipped => false }.merge(options))
				options[:flipped] ? "#{self.lastname}, #{self.firstname}".squeeze(" ") : "#{self.firstname} #{self.lastname}".squeeze(" ")
			else
				self.login
			end
		end
		alias :name :fullname
		
		def self.human_rolename(role)
			Alchemy::I18n.t("user_roles.#{role}")
		end
		
		def self.genders_for_select
			[
				[Alchemy::I18n.t('male'), 'male'],
				[Alchemy::I18n.t('female'), 'female']
			]
		end
		
		def self.all_online
			User.logged_in
		end
		
		def self.all_others_online
			User.logged_in.to_a.delete(self)
		end

	end
end
