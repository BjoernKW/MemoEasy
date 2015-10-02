require 'rails_helper'

describe Company do

  before(:each) do
    @attr = attributes_for(:company)
  end

  it "should create a new instance given a valid attribute" do
    Company.create!(@attr)
  end

  it "should require a name" do
    no_name_company = Company.new(@attr.merge(:name => ''))
    expect(no_name_company).to be_invalid
  end

  it "should require a reminder interval" do
    no_reminder_interval_company = Company.new(@attr.merge(:reminder_interval => nil))
    expect(no_reminder_interval_company).to be_invalid
  end

  it "should require a name with maximum length of 32 characters" do
    name_too_long_company = Company.new(@attr.merge(:name => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'))
    expect(name_too_long_company).to be_invalid
  end

  it "should not accept reserved names" do
    names = %w[www mail ftp]
    names.each do |name|
      reserved_name_company = Company.new(@attr.merge(:name => name))
      expect(reserved_name_company).to be_invalid
    end
  end
end
