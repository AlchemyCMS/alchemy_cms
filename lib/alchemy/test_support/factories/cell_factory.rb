require 'factory_girl'
require 'alchemy/test_support/factories/page_factory'

FactoryGirl.define do

  factory :alchemy_cell, class: 'Alchemy::Cell' do
    association :page, factory: :alchemy_page
    name "a_cell"
  end
end
