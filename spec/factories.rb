# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { "My Event" }
    hidden_name { "not shown" }
    location
    starts_at { Date.current }
    ends_at { Date.current + 1.day }
    lunch_starts_at { Time.local(2012, 0o3, 0o2, 12, 15) }
    lunch_ends_at { Time.local(2012, 0o3, 0o2, 13, 45) }
    description { "something\nfancy" }
    published { false }
    entrance_fee { 12.3 }
  end

  factory :location do
    name { "Awesome Lodge" }
  end

  factory :series do
    name { "My Series" }
  end
end
