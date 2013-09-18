require 'userstamp'
require 'acts-as-taggable-on'

module Alchemy
  class User < ActiveRecord::Base

    model_stamper
    stampable(:stamper_class_name => 'Alchemy::User')

    begin
      devise(*Config.get(:devise_modules))
    rescue NameError => e
      abort <<-WARN
You enabled the encryptable devise module, but did not have the `devise-encryptable` gem installed!
Please add the `devise-encryptable` gem into your Gemfile.
WARN
    end

    acts_as_taggable

    attr_accessible(
      :firstname,
      :lastname,
      :login,
      :email,
      :gender,
      :language,
      :password,
      :password_confirmation,
      :roles,
      :send_credentials,
      :tag_list
    )

    attr_accessor :send_credentials

    has_many :folded_pages

    validates_uniqueness_of :login
    validates_presence_of :roles

    # Unlock all locked pages before destroy and before the user gets logged out.
    before_destroy :unlock_pages!
    Warden::Manager.before_logout do |user, auth, opts|
      if user
        user.unlock_pages!
      end
    end

    after_save :deliver_welcome_mail, if: -> { send_credentials == '1' }

    scope :admins, where(arel_table[:roles].matches("%admin%")) # not pleased with that approach
    # mysql regexp word matching would be much nicer, but it's not included in SQLite functions per se.
    # scope :admins, where("#{table_name}.roles REGEXP '[[:<:]]admin[[:>:]]'")

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
      roles.map(&:to_sym)
    end

    def role
      roles.first
    end

    def roles
      read_attribute(:roles).split(' ')
    end

    def roles=(roles_string)
      if roles_string.is_a? Array
        write_attribute(:roles, roles_string.join(' '))
      elsif roles_string.is_a? String
        write_attribute(:roles, roles_string)
      end
    end

    def add_role(role)
      self.roles = self.roles.push(role.to_s).uniq
    end

    # Returns true if the user ahs admin role
    def is_admin?
      has_role? 'admin'
    end
    alias_method :admin?, :is_admin?

    # Returns true if the user has the given role.
    def has_role?(role)
      roles.include? role.to_s
    end

    # Calls unlock on all locked pages
    def unlock_pages!
      pages_locked_by_me.map(&:unlock!)
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

    def human_roles_string
      roles.map do |role|
        self.class.human_rolename(role)
      end.to_sentence
    end

    def store_request_time!
      update_attribute(:last_request_at, Time.now)
    end

  private

    def logged_in_timeout
      self.class.logged_in_timeout
    end

    # Delivers a welcome mail depending from user's role.
    #
    def deliver_welcome_mail
      if has_role?('author') || has_role?('editor') || has_role?('admin')
        Notifications.admin_user_created(self).deliver
      else
        Notifications.registered_user_created(self).deliver
      end
    end

  end
end
