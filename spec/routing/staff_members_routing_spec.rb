require "rails_helper"

describe StaffMembersController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/staff_members")).to route_to("staff_members#index")
    end

    it "routes to #new" do
      expect(get("/staff_members/new")).to route_to("staff_members#new")
    end

    it "routes to #show" do
      expect(get("/staff_members/1")).to route_to("staff_members#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/staff_members/1/edit")).to route_to("staff_members#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/staff_members")).to route_to("staff_members#create")
    end

    it "routes to #update" do
      expect(put("/staff_members/1")).to route_to("staff_members#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/staff_members/1")).to route_to("staff_members#destroy", :id => "1")
    end

  end
end
