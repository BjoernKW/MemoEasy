require 'rails_helper'

describe User do

  before(:each) do
    @company = Company.create!(attributes_for(:company))
    @attr = {
      :first_name => "Example",
      :last_name => "User",
      :email => "some_user@memoeasy.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "should create a new instance given a valid attribute" do
    user = User.new(@attr)
    expect(user).to be_invalid
    user.company = @company
    expect(user).to be_valid
  end

  it "should require a company" do
    no_company_user = User.new(@attr)
    expect(no_company_user).to be_invalid
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.company = @company
    expect(no_email_user).to be_invalid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.company = @company
      expect(valid_email_user).to be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.company = @company
      expect(invalid_email_user).to be_invalid
    end
  end

  it "should reject duplicate email addresses" do
    user = User.new(@attr)
    user.company = @company
    user.save
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.company = @company
    expect(user_with_duplicate_email).to be_invalid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    user = User.new(@attr.merge(:email => upcased_email))
    user.company = @company
    user.save
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.company = @company
    expect(user_with_duplicate_email).to be_invalid
  end

  describe "passwords" do

    before(:each) do
      @user = User.new(@attr)
      @user.company = @company
    end

    it "should have a password attribute" do
      expect(@user).to respond_to(:password)
    end

    it "should have a password confirmation attribute" do
      expect(@user).to respond_to(:password_confirmation)
    end
  end

  describe "password validations" do

    it "should require a password" do
      user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      user.company = @company
      expect(user).to be_invalid
    end

    it "should require a matching password confirmation" do
      user = User.new(@attr.merge(:password_confirmation => "invalid"))
      user.company = @company
      expect(user).to be_invalid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      user = User.new(hash)
      user.company = @company
      expect(user).to be_invalid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = User.new(@attr)
      @user.company = @company
      @user.save
    end

    it "should have an encrypted password attribute" do
      expect(@user).to respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      expect(@user.encrypted_password).not_to be_blank
    end

  end

  describe "#update_plan" do
    before do
      @user = FactoryGirl.create(:user, email: "test@memoeasy.com")
      @user.company = @company
      @role1 = FactoryGirl.create(:role, name: "silver")
      @role2 = FactoryGirl.create(:role, name: "gold")
      @user.add_role(@role1.name)
    end

    it "updates a users role" do
      expect(@user.roles.first.name).to eq "silver"
      @user.update_plan(@role2)
      expect(@user.roles.first.name).to eq "gold"
    end

    it "wont remove original role from database" do
      @user.update_plan(@role2)
      expect(Role.all.count).to eq 2
    end
  end

end
