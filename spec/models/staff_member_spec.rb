require 'rails_helper'

describe StaffMember do

  before(:each) do
    @attr = attributes_for(:staff_member)
    @company = Company.create!(attributes_for(:company))
  end

  it "should create a new instance given a valid attribute" do
    staff_member = StaffMember.new(@attr)
    expect(staff_member).to be_invalid
    staff_member.company = @company
    expect(staff_member).to be_valid
  end

  it "should require a company" do
    no_company_staff_member = StaffMember.new(@attr)
    expect(no_company_staff_member).to be_invalid
  end

  it "should require a name" do
    no_name_staff_member = StaffMember.new(@attr.merge(:name => ''))
    no_name_staff_member.company = @company
    expect(no_name_staff_member).to be_invalid
  end
end
