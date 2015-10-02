### UTILITY METHODS ###

def create_visitor
  @visitor ||= {
    :first_name => "Testy McUserton",
    :last_name => "McUserton",
    :email => "example@memoeasy.com",
    :password => "please",
    :password_confirmation => "please",
    :role => "starter",
    :company => "Some Company",
    :street_address => "Some Street",
    :postal_code => "11111",
    :city => "Some City",
    :confirmed_at => Time.now }
end

def find_user
  @user ||= User.where(email: @visitor[:email]).first
end

def create_unconfirmed_user
  create_visitor
  delete_user
  sign_up
  visit '/users/sign_out'
end

def create_user
  create_visitor
  delete_user
  @company = FactoryGirl.create(:company)
  @user = FactoryGirl.create(:user, email: @visitor[:email], company: @company)
  @user.add_role(@visitor[:role])
  @user.confirmed_at = Time.now
  @slot = FactoryGirl.create(:slot)
end

def delete_user
  @user ||= User.where(email: @visitor[:email]).first
  @user.destroy unless @user.nil?
end

def sign_up
  delete_user
  visit '/users/sign_up/?plan=silver'
  fill_in "First name", :with => @visitor[:first_name]
  fill_in "Last name", :with => @visitor[:last_name]
  fill_in "Company", :with => @visitor[:company]
  fill_in "Street / number", :with => @visitor[:street_address]
  fill_in "Postal code", :with => @visitor[:postal_code]
  fill_in "City", :with => @visitor[:city]
  fill_in "eMail", :with => @visitor[:email]
  fill_in "user_password", :with => @visitor[:password]
  fill_in "user_password_confirmation", :with => @visitor[:password_confirmation]
  click_button "Sign up"
  find_user
end

def sign_in
  visit '/users/sign_in'
  fill_in "eMail", :with => @visitor[:email]
  fill_in "Password", :with => @visitor[:password]
  click_button "Log in"
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit destroy_user_session_path
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up without a plan$/ do
  visit '/users/sign_up'
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "please123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(:email => "wrong@memoeasy.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I change my email address$/ do
  click_link "Edit account"
  fill_in "user_email", :with => "different@memoeasy.com"
  fill_in "user_current_password", :with => @visitor[:password]
  click_button "update_user"
end

When /^I delete my account$/ do
  click_link "Edit account"
  click_link "Cancel my account"
  click_link "Yes, I'm sure."
end

When /^I follow the subscribe for silver path$/ do
  visit '/users/sign_up/?plan=silver'
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content "Log out"
  page.should_not have_content "Sign up"
  page.should_not have_content "Log in"
end

Then /^I should be signed out$/ do
  page.should have_content "Log in"
  page.should_not have_content "Log out"
end

Then /^I should see "(.*?)"$/ do |text|
  page.should have_content text
end

Then /^I should be on the "([^"]*)" page$/ do |path_name|
  current_path.should == send("#{path_name.parameterize('_')}_path")
end

Then /^I should be on the root page$/ do
  current_path.should == '/'
end

Then /I should be on the new silver user registration page$/ do
  current_path_with_args.should == '/users/sign_up/?plan=silver'
end

Then /^I see an unconfirmed account message$/ do
  page.should have_content "You have to confirm your account before continuing."
end

Then /^I see a successful sign in message$/ do
  page.should have_content "Welcome back."
end

Then /^I should see a confirmation link message$/ do
  page.should have_content "A message with a confirmation link has been sent to your eMail address. Please open the link to activate your account."
end

Then /^I should see an invalid email message$/ do
  page.should have_content "is invalid"
end

Then /^I should see a missing password message$/ do
  page.should have_content "can't be blank"
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content "doesn't match confirmation"
end

Then /^I should see a mismatched password message$/ do
  page.should have_content "doesn't match confirmation"
end

Then /^I should see a missing plan message$/ do
  page.should have_content "Please select a plan below"
end

Then /^I should see a signed out message$/ do
  page.should have_content "See you soon."
end

Then /^I see an invalid login message$/ do
  page.should have_content "Invalid eMail or password."
end

Then /^I should see an account edited message$/ do
  page.should have_content "You updated your account successfully, but we need to verify your new eMail address. Please check your eMail and click on the confirm link to finalize confirming your new eMail address."
end

Then /^I should see an account deleted message$/ do
  page.should have_content "account was successfully cancelled"
end

Then /^I should see my name$/ do
  create_user
  page.should have_content @user[:name]
end
