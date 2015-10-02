require 'rails_helper'

describe "Services" do
  
  describe "GET /services" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get services_url
      expect(response.status).to be(302)
    end
  end
end
