require 'devise/orm/active_record'
require 'acts-as-taggable-on'
require 'userstamp'

module Alchemy
  class User < ActiveRecord::Base
    PERMITTED_ATTRIBUTES = [
      :firstname,
      :lastname,
      :login,
      :email,
      :gender,
      :language,
      :password,
      :password_confirmation,
      :send_credentials,
      :tag_list
    ]
    DEVISE_MODULES = [
      :database_authenticatable,
      :trackable,
      :validatable,
      :timeoutable,
      :recoverable
    ]
    # If the app uses an old encryption it uses the devise-encryptable gem
    # therefore we have to load the devise module
    if (::Devise::Models::Encryptable rescue false)
      DEVISE_MODULES.push(:encryptable)
    end
    devise *DEVISE_MODULES

    acts_as_taggable
    acts_as_tagger

    attr_accessor :send_credentials

    has_many :folded_pages

    validates_uniqueness_of :login
    validates_presence_of :alchemy_roles

    # Unlock all locked pages before destroy.
    before_destroy :unlock_pages!

    scope :admins,     -> { where(arel_table[:alchemy_roles].matches('%admin%')) }
    scope :logged_in,  -> { where('last_request_at > ?', logged_in_timeout.seconds.ago) }
    scope :logged_out, -> { where('last_request_at is NULL or last_request_at <= ?', logged_in_timeout.seconds.ago) }

    ROLES = Config.get(:user_roles)

    class << self
      def human_rolename(role)
        Alchemy.t("user_roles.#{role}")
      end

      def genders_for_select
        [
          [Alchemy.t('male'), 'male'],
          [Alchemy.t('female'), 'female']
        ]
      end

      def logged_in_timeout
        Config.get(:auto_logout_time).minutes.to_i
      end

      # Search users that match query
      #
      # Attributes searched are: login, email, firstname, lastname
      #
      def search(query)
        query = "%#{query.downcase}%"

        where arel_table[:login].lower.matches(query)
          .or arel_table[:email].lower.matches(query)
          .or arel_table[:firstname].lower.matches(query)
          .or arel_table[:lastname].lower.matches(query)
      end
    end

    def role_symbols
      alchemy_roles.map(&:to_sym)
    end

    def role
      alchemy_roles.first
    end

    def alchemy_roles
      read_attribute(:alchemy_roles).split(' ')
    end

    def alchemy_roles=(roles_string)
      if roles_string.is_a? Array
        write_attribute(:alchemy_roles, roles_string.join(' '))
      elsif roles_string.is_a? String
        write_attribute(:alchemy_roles, roles_string)
      end
    end

    def add_role(role)
      self.alchemy_roles = self.alchemy_roles.push(role.to_s).uniq
    end

    # Returns true if the user ahs admin role
    def is_admin?
      has_role? 'admin'
    end
    alias_method :admin?, :is_admin?

    # Returns true if the user has the given role.
    def has_role?(role)
      alchemy_roles.include? role.to_s
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
      Page.locked_by(self).order(:updated_at)
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
    alias_method :alchemy_display_name, :fullname

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
      alchemy_roles.map do |role|
        self.class.human_rolename(role)
      end.to_sentence
    end

    def store_request_time!
      update_column(:last_request_at, Time.now)
    end

    # Delivers a welcome mail depending from user's role.
    #
    def deliver_welcome_mail
      if has_role?('author') || has_role?('editor') || has_role?('admin')
        Notifications.alchemy_user_created(self).deliver_later
      else
        Notifications.member_created(self).deliver_later
      end
    end

    private

    def logged_in_timeout
      self.class.logged_in_timeout
    end
  end
end
