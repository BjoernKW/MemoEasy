# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name 'Test'
    last_name 'User'
    email 'test_user@memoeasy.com'
    password 'please'
    password_confirmation 'please'
    confirmed_at Time.now
    company

    factory :admin do
      after(:create) { |user| user.add_role(:admin) }
    end
    
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
end
