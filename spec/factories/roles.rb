FactoryGirl.define do
	factory :role do
    name 'default'
  end

  factory :admin_role, class: Role do
    name 'admin'
  end
end
