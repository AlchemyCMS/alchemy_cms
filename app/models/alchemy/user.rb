module Alchemy
  class User < ActiveRecord::Base

    model_stamper
    stampable(:stamper_class_name => 'Alchemy::User')

    devise(*Config.get(:devise_modules))

    acts_as_taggable

    attr_accessible(
      :firstname,
      :lastname,
      :login,
      :email,
      :gender,
      :role,
      :language,
      :password,
      :password_confirmation,
      :tag_list
    )

    has_many :folded_pages

    # Unlock all locked pages before destroy and before the user gets logged out.
    before_destroy :unlock_pages!
    Warden::Manager.before_logout do |user, auth, opts|
      if user
        user.unlock_pages!
      end
    end

    scope :admins, where(:role => 'admin')
    scope :logged_in, lambda { where("last_request_at > ?", logged_in_timeout.seconds.ago) }
    scope :logged_out, lambda { where("last_request_at is NULL or last_request_at <= ?", logged_in_timeout.seconds.ago) }

    ROLES = Config.get(:user_roles)

    class << self
      def human_rolename(role)
        I18n.t("user_roles.#{role}")
      end

      def genders_for_select
        [
          [I18n.t('male'), 'male'],
          [I18n.t('female'), 'female']
        ]
      end

      def logged_in_timeout
        Config.get(:auto_logout_time).minutes.to_i
      end
    end

    def role_symbols
      [role.to_sym]
    end

    # Returns true if the user ahs admin role
    def is_admin?
      role == "admin"
    end
    alias_method :admin?, :is_admin?

    # Calls unlock on all locked pages
    def unlock_pages!
      pages_locked_by_me.map(&:unlock)
    end

    # Returns all pages locked by user.
    #
    # A page gets locked, if the user requests to edit the page.
    #
    def pages_locked_by_me
      Page.where(:locked => true).where(:locked_by => self.id).order(:updated_at)
    end
    alias_method :locked_pages, :pages_locked_by_me

    # Returns the firstname and lastname as a string
    #
    # If both are blank, returns the login
    #
    # @option options :flipped (false)
    #   Flip the firstname and lastname
    #
    def fullname(options = {})
      if lastname.blank? && firstname.blank?
        login
      else
        options = {:flipped => false}.merge(options)
        fullname = options[:flipped] ? "#{lastname}, #{firstname}" : "#{firstname} #{lastname}"
        fullname.squeeze(" ").strip
      end
    end
    alias_method :name, :fullname

    # Returns true if the last request not longer ago then the logged_in_time_out
    def logged_in?
      raise "Can not determine the records login state because there is no last_request_at column" if !respond_to?(:last_request_at)
      !last_request_at.nil? && last_request_at > logged_in_timeout.seconds.ago
    end

    # Opposite of logged_in?
    def logged_out?
      !logged_in?
    end

    def human_role_name
      self.class.human_rolename(self.role)
    end

    def store_request_time!
      update_attribute(:last_request_at, Time.now)
    end

  private

    def logged_in_timeout
      self.class.logged_in_timeout
    end

  end
end
