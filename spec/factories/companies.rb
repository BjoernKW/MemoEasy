# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company do
    name "MyString"
    street_address "MyString"
    postal_code "MyString"
    city "MyString"
    company_register_id "MyString"
    bank_account_number "MyString"
    bank_id "MyString"
    bank_name "MyString"
    use_html_email true
    use_text_email true
    use_text_message true
    reminder_interval 86400
  end
end
