# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_essence_texts
#
#  id              :integer          not null, primary key
#  body            :text
#  link            :string
#  link_title      :string
#  link_class_name :string
#  public          :boolean          default(FALSE)
#  link_target     :string
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

module Alchemy
  class EssenceText < BaseRecord
    acts_as_essence
  end
end
