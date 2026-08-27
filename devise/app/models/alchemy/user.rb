# frozen_string_literal: true

require "devise/orm/active_record"
require "userstamp"

module Alchemy
  class User < ActiveRecord::Base
    PERMITTED_ATTRIBUTES = [
      :firstname,
      :lastname,
      :login,
      :email,
      :language,
      :password,
      :password_confirmation,
      :send_credentials,
      :tag_list,
      :timezone
    ]

    devise(*Alchemy::Devise.config.devise_modules)

    include Alchemy::Taggable
    include Alchemy::UserMethods

    attr_accessor :send_credentials

    has_many :folded_pages

    validates :login, uniqueness: {case_sensitive: false}, presence: :login_required?

    scope :admins, -> {
      Alchemy::Deprecation.warn("#{name}.admins is deprecated. Please use #{name}.alchemy_admins instead.")
      alchemy_admins
    }

    scope :logged_in, -> { where("last_request_at > ?", logged_in_timeout.seconds.ago) }
    scope :logged_out, -> { where("last_request_at is NULL or last_request_at <= ?", logged_in_timeout.seconds.ago) }

    ROLES = Alchemy.config.user_roles

    class << self
      def ransackable_attributes(_auth_object = nil)
        %w[
          email
          firstname
          lastname
          login
        ]
      end

      def ransortable_attributes(_auth_object = nil)
        %w[last_sign_in_at]
      end

      alias_method :searchable_alchemy_resource_attributes, :ransackable_attributes

      def ransackable_associations(_auth_object = nil)
        %w[
          taggings
          tags
        ]
      end

      deprecate human_rolename: :human_alchemy_rolename, deprecator: Alchemy::Deprecation
      alias_method :human_rolename, :human_alchemy_rolename

      def logged_in_timeout
        Alchemy.config.get(:auto_logout_time).minutes.to_i
      end
    end

    def role_symbols
      alchemy_roles.map(&:to_sym)
    end
    deprecate :role_symbols, deprecator: Alchemy::Deprecation

    def role
      alchemy_roles.first
    end
    deprecate :role, deprecator: Alchemy::Deprecation

    def add_role(role)
      self.alchemy_roles = alchemy_roles.push(role.to_s).uniq
    end
    deprecate add_role: :"alchemy_roles=", deprecator: Alchemy::Deprecation

    alias_method :is_admin?, :alchemy_admin?
    deprecate is_admin?: :alchemy_admin?, deprecator: Alchemy::Deprecation

    alias_method :has_role?, :has_alchemy_role?
    deprecate has_role?: :has_alchemy_role?, deprecator: Alchemy::Deprecation

    alias_method :human_roles_string, :human_alchemy_roles
    deprecate human_roles_string: :human_alchemy_roles, deprecator: Alchemy::Deprecation

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
        options = {flipped: false}.merge(options)
        fullname = options[:flipped] ? "#{lastname}, #{firstname}" : "#{firstname} #{lastname}"
        fullname.squeeze(" ").strip
      end
    end

    alias_method :name, :fullname
    alias_method :alchemy_display_name, :fullname

    def email_required?
      ::Devise.authentication_keys.include?(:email)
    end

    def login_required?
      ::Devise.authentication_keys.include?(:login)
    end

    # Returns true if the last request not longer ago then the logged_in_time_out
    def logged_in?
      raise "Can not determine the records login state because there is no last_request_at column" if !respond_to?(:last_request_at)
      !last_request_at.nil? && last_request_at > logged_in_timeout.seconds.ago
    end

    # Opposite of logged_in?
    def logged_out?
      !logged_in?
    end

    alias_method :pages_locked_by_me, :locked_pages
    deprecate pages_locked_by_me: :locked_pages, deprecator: Alchemy::Deprecation

    def store_request_time!
      update_column(:last_request_at, Time.now)
    end

    # Delivers a welcome mail depending from user's role.
    #
    def deliver_welcome_mail
      if has_alchemy_role?("author") || has_alchemy_role?("editor") || has_alchemy_role?("admin")
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
