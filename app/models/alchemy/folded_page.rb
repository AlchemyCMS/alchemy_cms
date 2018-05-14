# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_folded_pages
#
#  id      :integer          not null, primary key
#  page_id :integer          not null
#  user_id :integer          not null
#  folded  :boolean          default(FALSE)
#

module Alchemy
  class FoldedPage < BaseRecord
    belongs_to :page, inverse_of: :folded_pages
    belongs_to :user, inverse_of: :folded_pages, class_name: Alchemy.user_class_name

    def self.folded_for_user(user)
      return none unless Alchemy.user_class < ActiveRecord::Base
      where(user: user, folded: true)
    end
  end
end
