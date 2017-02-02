require 'factory_girl'

FactoryGirl.define do
  factory :alchemy_site, class: 'Alchemy::Site' do
    name 'A Site'
    sequence(:host) { |i| "www#{i}.domain.com" }

    trait :public do
      public true
    end
  end
end
