# frozen_string_literal: true

class DummyUser < ActiveRecord::Base
  has_many :folded_pages, class_name: "Alchemy::FoldedPage"
  has_and_belongs_to_many :languages, class_name: "Alchemy::Language", foreign_key: :user_id, join_table: :alchemy_users_languages

  attr_writer :alchemy_roles, :name

  def self.logged_in
    []
  end

  def self.admins
    [first].compact
  end

  def alchemy_roles
    @alchemy_roles || %w(admin)
  end

  def name
    @name || email
  end

  def human_roles_string
    alchemy_roles.map(&:humanize)
  end

  # Languages this user is allowed to access
  #
  # An empty collection means allow all languages
  #
  def accessible_languages
    languages.any? ? languages : Alchemy::Language.all
  end
end
