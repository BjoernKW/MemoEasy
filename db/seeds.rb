# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.where(:name => role).first_or_create(:name => role)
  puts 'role: ' << role
end

puts 'DEFAULT COMPANIES'
company = Company.where(:name => 'SimDuctive').first_or_create(:name => '', :street_address => '', :postal_code => '', :city => '', :reminder_interval => 1800)
puts 'company: ' << company.name

puts 'DEFAULT USERS'
user = User.find_by_email ENV['ADMIN_EMAIL'].dup
unless user
	user = User.new :first_name => ENV['ADMIN_FIRST_NAME'].dup, :last_name => ENV['ADMIN_LAST_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
	user.company = company
	user.confirmed_at = Time.now
	user.add_role :admin
	user.save 
end
puts 'user: ' << user.name

user2 = User.find_by_email 'starter@memoeasy.com'
unless user2
	user2 = User.new :first_name => 'Starter', :last_name => 'User', :email => 'starter@memoeasy.com', :password => 'please', :password_confirmation => 'please'
	user2.company = company
	user2.confirmed_at = Time.now
	user2.add_role :starter
	user2.save 
end

user3 = User.find_by_email 'professional@memoeasy.com'
unless user3
	user3 = User.new :first_name => 'Professional', :last_name => 'User', :email => 'professional@memoeasy.com', :password => 'please', :password_confirmation => 'please'
	user3.company = company
	user3.confirmed_at = Time.now
	user3.add_role :professional
	user3.save 
end

user4 = User.find_by_email 'business@memoeasy.com'
unless user4
	user4 = User.new :first_name => 'Business', :last_name => 'User', :email => 'business@memoeasy.com', :password => 'please', :password_confirmation => 'please'
	user4.company = company
	user4.confirmed_at = Time.now
	user4.add_role :business
	user4.save 
end

puts "users: #{user2.name}, #{user3.name}, #{user4.name}"
