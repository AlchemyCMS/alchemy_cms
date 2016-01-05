require 'factory_girl'

FactoryGirl.define do

  factory :alchemy_node, class: 'Alchemy::Node' do
    name 'A Node'
    language { Alchemy::Language.default }
  end
end
