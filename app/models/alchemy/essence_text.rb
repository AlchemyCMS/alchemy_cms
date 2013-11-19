# == Schema Information
#
# Table name: alchemy_essence_texts
#
#  id              :integer          not null, primary key
#  body            :text
#  link            :string(255)
#  link_title      :string(255)
#  link_class_name :string(255)
#  public          :boolean          default(FALSE)
#  link_target     :string(255)
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

module Alchemy
  class EssenceText < ActiveRecord::Base
    acts_as_essence
  end
end
