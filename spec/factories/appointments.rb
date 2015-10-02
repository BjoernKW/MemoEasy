# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :appointment do
    starts_at "2012-12-25 23:43:44"
    ends_at "2012-12-25 23:43:44"
    remind_at "2012-12-25 23:43:44"
    notes ""
    use_html_email true
    use_text_email true
    use_text_message true
    company
    user
    customer
    service
    staff_member
  end
end
