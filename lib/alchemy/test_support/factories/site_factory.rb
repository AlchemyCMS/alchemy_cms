require 'factory_girl'

FactoryGirl.define do

  factory :alchemy_site, class: 'Alchemy::Site' do
    name 'A Site'
    host 'domain.com'
  end
end
