# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_site, class: "Alchemy::Site" do
    name { "A Site" }
    host { "domain.com" }

    trait :default do
      public { true }

      name { Alchemy::Config.get(:default_site)["name"] }
      host { Alchemy::Config.get(:default_site)["host"] }
    end

    trait :public do
      public { true }
    end
  end
end
