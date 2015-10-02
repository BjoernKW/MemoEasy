require "rails_helper"

describe SlotsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/slots")).to route_to("slots#index")
    end

    it "routes to #new" do
      expect(get("/slots/new")).to route_to("slots#new")
    end

    it "routes to #show" do
      expect(get("/slots/1")).to route_to("slots#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/slots/1/edit")).to route_to("slots#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/slots")).to route_to("slots#create")
    end

    it "routes to #update" do
      expect(put("/slots/1")).to route_to("slots#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/slots/1")).to route_to("slots#destroy", :id => "1")
    end

  end
end
