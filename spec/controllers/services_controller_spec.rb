require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ServicesController do

  login_user
  render_views

  before(:each) do
    @service = FactoryGirl.create(:service, :company => @company)
  end

  # This should return the minimal set of attributes required to create a valid
  # Service. As you add validations to Service, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    attributes_for(:service)
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ServicesController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all services as @services" do
      get :index, {}
      expect(assigns(:services)).to eq([@service])
    end
  end

  describe "GET show" do
    it "assigns the requested service as @service" do
      get :show, {:id => @service.to_param}
      expect(assigns(:service)).to eq(@service)
    end
  end

  describe "GET new" do
    it "assigns a new service as @service" do
      get :new, {}
      expect(assigns(:service)).to be_a_new(Service)
    end
  end

  describe "GET edit" do
    it "assigns the requested service as @service" do
      get :edit, {:id => @service.to_param}
      expect(assigns(:service)).to eq(@service)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Service" do
        expect {
          post :create, {:service => valid_attributes}
        }.to change(Service, :count).by(1)
      end

      it "assigns a newly created service as @service" do
        post :create, {:service => valid_attributes}
        expect(assigns(:service)).to be_a(Service)
        expect(assigns(:service)).to be_persisted
      end

      it "redirects to service list" do
        post :create, {:service => valid_attributes}
        expect(response).to redirect_to(services_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved service as @service" do
        # Trigger the behavior that occurs when invalid params are submitted
        Service.any_instance.stub(:save).and_return(false)
        post :create, {:service => {  }}
        expect(assigns(:service)).to be_a_new(Service)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Service.any_instance.stub(:save).and_return(false)
        post :create, {:service => {  }}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested service" do
        # Assuming there are no other services in the database, this
        # specifies that the Service created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Service.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => @service.to_param, :service => { "these" => "params" }}
      end

      it "assigns the requested service as @service" do
        put :update, {:id => @service.to_param, :service => valid_attributes}
        expect(assigns(:service)).to eq(@service)
      end

      it "redirects to the service" do
        put :update, {:id => @service.to_param, :service => valid_attributes}
        expect(response).to redirect_to(@service)
      end
    end

    describe "with invalid params" do
      it "assigns the service as @service" do
        # Trigger the behavior that occurs when invalid params are submitted
        Service.any_instance.stub(:save).and_return(false)
        put :update, {:id => @service.to_param, :service => {  }}
        expect(assigns(:service)).to eq(@service)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Service.any_instance.stub(:save).and_return(false)
        put :update, {:id => @service.to_param, :service => {  }}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested service" do
      expect {
        delete :destroy, {:id => @service.to_param}
      }.to change(Service, :count).by(-1)
    end

    it "redirects to the services list" do
      delete :destroy, {:id => @service.to_param}
      expect(response).to redirect_to(services_url)
    end
  end

end