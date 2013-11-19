# == Schema Information
#
# Table name: alchemy_essence_links
#
#  id              :integer          not null, primary key
#  link            :string(255)
#  link_title      :string(255)
#  link_target     :string(255)
#  link_class_name :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  updater_id      :integer
#

module Alchemy
  class EssenceLink < ActiveRecord::Base
    acts_as_essence ingredient_column: 'link'
  end
end
