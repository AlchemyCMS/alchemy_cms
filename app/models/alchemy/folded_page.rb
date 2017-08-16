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
  class FoldedPage < ActiveRecord::Base
    belongs_to :page, required: true
    belongs_to :user, required: true,
      class_name: Alchemy.user_class_name
  end
end
