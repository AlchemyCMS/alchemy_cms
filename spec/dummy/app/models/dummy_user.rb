# frozen_string_literal: true

class DummyUser < ActiveRecord::Base
  include Alchemy::UserMethods

  has_many :folded_pages, class_name: "Alchemy::FoldedPage"
  attr_writer :name

  def self.logged_in
    []
  end

  def name
    @name || email
  end

  def alchemy_display_name
    name
  end

  def sign_in_count = 0
  def last_sign_in_at = Date.yesterday
end
