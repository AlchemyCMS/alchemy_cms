require 'factory_girl'

FactoryGirl.define do
  factory :alchemy_page_version, class: 'Alchemy::PageVersion' do
    association :page, factory: :alchemy_page
  end
end
