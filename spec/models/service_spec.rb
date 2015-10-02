require 'rails_helper'

describe Service do

  before(:each) do
    @attr = attributes_for(:service)
    @company = Company.create!(attributes_for(:company))
  end

  it "should create a new instance given a valid attribute" do
    service = Service.new(@attr)
    expect(service).to be_invalid
    service.company = @company
    expect(service).to be_valid
  end

  it "should require a company" do
    no_company_service = Service.new(@attr)
    expect(no_company_service).to be_invalid
  end

  it "should require a name" do
    no_name_service = Service.new(@attr.merge(:name => ''))
    no_name_service.company = @company
    expect(no_name_service).to be_invalid
  end

  it "should require a duration" do
    no_duration_service = Service.new(@attr.merge(:duration => nil))
    no_duration_service.company = @company
    expect(no_duration_service).to be_invalid
  end
end
