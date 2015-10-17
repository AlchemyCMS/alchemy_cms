FactoryGirl.define do

  factory :event do
    name 'My Event'
    hidden_name 'not shown'
    starts_at DateTime.new(2012, 03, 02, 8, 15)
    ends_at DateTime.new(2012, 03, 02, 19, 30)
    lunch_starts_at DateTime.new(2012, 03, 02, 12, 15)
    lunch_ends_at DateTime.new(2012, 03, 02, 13, 45)
    description "something\nfancy"
    published false
    entrance_fee 12.3
  end
end
