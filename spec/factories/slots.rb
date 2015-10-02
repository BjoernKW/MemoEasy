# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :slot do
    company
    starts_at_hour 0
    starts_at_minute 0
    ends_at_hour 0
    ends_at_minute 10
    weekday 1
  end
end
