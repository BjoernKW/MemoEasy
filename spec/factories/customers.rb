# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :customer do
    first_name "MyString"
    last_name "MyString"
    mobile_phone "MyString"
    email "some@test.com"
    use_html_email true
    use_text_email true
    use_text_message true
    company
  end
end
