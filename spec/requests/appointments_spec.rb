require 'rails_helper'

describe "Appointments" do

  describe "GET /appointments" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get appointments_url
      expect(response.status).to be(302)
    end
  end
end
