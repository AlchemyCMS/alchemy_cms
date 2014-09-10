require 'factory_girl'

FactoryGirl.define do

  factory :node, class: 'Alchemy::Node' do
    name 'A Node'
    language { Alchemy::Language.default }
  end
end
