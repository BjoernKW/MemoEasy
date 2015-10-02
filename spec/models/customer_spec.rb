require 'rails_helper'

describe Customer do

  before(:each) do
    @attr = attributes_for(:customer)
    @company = Company.create!(attributes_for(:company))
  end

  it "should create a new instance given a valid attribute" do
    customer = Customer.new(@attr)
    expect(customer).to be_invalid
    customer.company = @company
    expect(customer).to be_valid
  end

  it "should require a company" do
    no_company_customer = Customer.new(@attr)
    expect(no_company_customer).to be_invalid
  end

  it "should require a first name" do
    no_first_name_customer = Customer.new(@attr.merge(:first_name => ''))
    no_first_name_customer.company = @company
    expect(no_first_name_customer).to be_invalid
  end

  it "should require a last name" do
    no_last_name_customer = Customer.new(@attr.merge(:last_name => ''))
    no_last_name_customer.company = @company
    expect(no_last_name_customer).to be_invalid
  end

  it "should require an email address or a mobile phone number" do
    no_contact_customer = Customer.new(@attr.merge(:email => "", :mobile_phone => ""))
    no_contact_customer.company = @company
    expect(no_contact_customer).to be_invalid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_customer = Customer.new(@attr.merge(:email => address))
      valid_email_customer.company = @company
      expect(valid_email_customer).to be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_customer = Customer.new(@attr.merge(:email => address))
      invalid_email_customer.company = @company
      expect(invalid_email_customer).to be_invalid
    end
  end
end
