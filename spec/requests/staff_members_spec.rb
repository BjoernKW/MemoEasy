require 'rails_helper'

describe "StaffMembers" do

  describe "GET /staff_members" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get staff_members_url
      expect(response.status).to be(302)
    end
  end
end
