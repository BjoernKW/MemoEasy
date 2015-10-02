require 'rails_helper'

describe "Slots" do

  describe "GET /slots" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get slots_url
      expect(response.status).to be(302)
    end
  end
end
