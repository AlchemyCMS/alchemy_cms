require 'factory_girl'

FactoryGirl.define do

  factory :alchemy_dummy_user, class: 'DummyUser' do
    sequence(:email) do |n| "john.#{n}@doe.com" end
    password 's3cr3t'
    alchemy_roles ['member']

    trait :as_admin do
      alchemy_roles ['admin']
    end

    trait :as_author do
      alchemy_roles ['author']
    end

    trait :as_editor do
      alchemy_roles ['editor']
    end
  end
end
