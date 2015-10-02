require 'rails_helper'

describe Appointment do

  before(:each) do
    @attr = attributes_for(:appointment)
    @company = Company.create!(attributes_for(:company))
    customer = Customer.new(attributes_for(:customer))
    customer.company = @company
    customer.save
    service = Service.new(attributes_for(:service))
    service.company = @company
    service.save
    staff_member = StaffMember.new(attributes_for(:staff_member))
    staff_member.company = @company
    staff_member.save
    @attr = @attr.merge(:customer => customer, :service => service, :staff_member => staff_member)
  end

  it "should create a new instance given a valid attribute" do
    appointment = Appointment.new(@attr)
    expect(appointment).not_to be_valid
    appointment.company = @company
    expect(appointment).to be_valid
  end

  it "should require a company" do
    no_company_appointment = Appointment.new(@attr)
    expect(no_company_appointment).not_to be_valid
  end

  it "should require a customer" do
    no_customer_appointment = Appointment.new(@attr.merge(:customer => nil))
    no_customer_appointment.company = @company
    expect(no_customer_appointment).not_to be_valid
  end

    it "should require a service" do
    no_service_appointment = Appointment.new(@attr.merge(:service => nil))
    no_service_appointment.company = @company
    expect(no_service_appointment).not_to be_valid
  end

    it "should require a staff member" do
    no_staff_member_appointment = Appointment.new(@attr.merge(:staff_member => nil))
    no_staff_member_appointment.company = @company
    expect(no_staff_member_appointment).not_to be_valid
  end

  it "should require a start date" do
    no_start_date_appointment = Appointment.new(@attr.merge(:starts_at => ''))
    no_start_date_appointment.company = @company
    expect(no_start_date_appointment).not_to be_valid
  end

  it "should require an end date" do
    no_end_date_appointment = Appointment.new(@attr.merge(:ends_at => ''))
    no_end_date_appointment.company = @company
    expect(no_end_date_appointment).not_to be_valid
  end
end
