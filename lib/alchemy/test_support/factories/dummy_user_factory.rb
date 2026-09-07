# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_dummy_user, class: "DummyUser" do
    sequence(:email) { |n| "john.#{n}@doe.com" }
    password { "s3cr3t" }

    trait :as_member do
      alchemy_roles { ["member"] }
    end

    trait :as_admin do
      alchemy_roles { ["admin"] }
    end

    trait :as_author do
      alchemy_roles { ["author"] }
    end

    trait :as_editor do
      alchemy_roles { ["editor"] }
    end
  end
end
