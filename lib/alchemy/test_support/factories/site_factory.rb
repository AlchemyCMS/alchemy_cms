require 'factory_girl'

FactoryGirl.define do

  factory :alchemy_site, class: 'Alchemy::Site' do
    name 'A Site'
    host 'domain.com'

    trait :public do
      public true
    end
  end
end
