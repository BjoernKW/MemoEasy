require 'rails_helper'

describe Slot do

  before(:each) do
    @attr = attributes_for(:slot)
    @company = Company.create!(attributes_for(:company))
  end

  it "should create a new instance given a valid attribute" do
    slot = Slot.new(@attr)
    expect(slot).to be_invalid
    slot.company = @company
    expect(slot).to be_valid
  end

  it "should require a company" do
    no_company_slot = Slot.new(@attr)
    expect(no_company_slot).to be_invalid
  end

  it "should require a start hour" do
    no_start_hour_slot = Slot.new(@attr.merge(:starts_at_hour => nil))
    no_start_hour_slot.company = @company
    expect(no_start_hour_slot).to be_invalid
  end

  it "should require a start minute" do
    no_start_minute_slot = Slot.new(@attr.merge(:starts_at_minute => nil))
    no_start_minute_slot.company = @company
    expect(no_start_minute_slot).to be_invalid
  end

  it "should require an end hour" do
    no_end_hour_slot = Slot.new(@attr.merge(:ends_at_hour => nil))
    no_end_hour_slot.company = @company
    expect(no_end_hour_slot).to be_invalid
  end

  it "should require an end hour" do
    no_end_minute_slot = Slot.new(@attr.merge(:ends_at_minute => nil))
    no_end_minute_slot.company = @company
    expect(no_end_minute_slot ).to be_invalid
  end

  it "should require a weekday" do
    no_weekday_slot = Slot.new(@attr.merge(:weekday => nil))
    no_weekday_slot.company = @company
    expect(no_weekday_slot).to be_invalid
  end

  it "should require a start time that is before the end time" do
    end_time_before_start_time_slot = Slot.new(
      @attr.merge(
        :starts_at_hour => 10,
        :starts_at_minute => 0,
        :ends_at_hour => 9,
        :ends_at_minute => 0))
    end_time_before_start_time_slot.company = @company
    expect(end_time_before_start_time_slot).to be_invalid

    end_time_before_start_time_slot = Slot.new(
      @attr.merge(
        :starts_at_hour => 10,
        :starts_at_minute => 30,
        :ends_at_hour => 10,
        :ends_at_minute => 10))
    end_time_before_start_time_slot.company = @company
    expect(end_time_before_start_time_slot).to be_invalid
  end
end
