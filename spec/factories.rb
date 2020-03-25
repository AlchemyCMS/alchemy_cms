# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { 'My Event' }
    hidden_name { 'not shown' }
    location
    starts_at { Time.local(2012, 03, 02, 8, 15) }
    ends_at { Time.local(2012, 03, 02, 19, 30) }
    lunch_starts_at { Time.local(2012, 03, 02, 12, 15) }
    lunch_ends_at { Time.local(2012, 03, 02, 13, 45) }
    description { "something\nfancy" }
    published { false }
    entrance_fee { 12.3 }
  end

  factory :location do
    name { 'Awesome Lodge' }
  end

  factory :series do
    name { 'My Series' }
  end
end
