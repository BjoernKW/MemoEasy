require 'rails_helper'

describe CustomersController do

  login_user
  render_views

  before(:each) do
    @customer = FactoryGirl.create(:customer, :company => @company)
  end

  # This should return the minimal set of attributes required to create a valid
  # Customer. As you add validations to Customer, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    attributes_for(:customer)
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CustomersController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all customers as @customers" do
      get :index, {}
      expect(assigns(:customers)).to eq([@customer])
    end
  end

  describe "GET show" do
    it "assigns the requested customer as @customer" do
      get :show, {:id => @customer.to_param}
      expect(assigns(:customer)).to eq(@customer)
    end
  end

  describe "GET new" do
    it "assigns a new customer as @customer" do
      get :new, {}
      expect(assigns(:customer)).to be_a_new(Customer)
    end
  end

  describe "GET edit" do
    it "assigns the requested customer as @customer" do
      get :edit, {:id => @customer.to_param}
      expect(assigns(:customer)).to eq(@customer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new customer" do
        expect {
          post :create, {:customer => valid_attributes}
        }.to change(Customer, :count).by(1)
      end

      it "assigns a newly created customer as @customer" do
        post :create, {:customer => valid_attributes}
        expect(assigns(:customer)).to be_a(Customer)
        expect(assigns(:customer)).to be_persisted
      end

      it "redirects to customer list" do
        post :create, {:customer => valid_attributes}
        expect(response).to redirect_to(customers_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved customer as @customer" do
        # Trigger the behavior that occurs when invalid params are submitted
        Customer.any_instance.stub(:save).and_return(false)
        post :create, {:customer => {  }}
        expect(assigns(:customer)).to be_a_new(Customer)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Customer.any_instance.stub(:save).and_return(false)
        post :create, {:customer => {  }}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested customer" do
        # Assuming there are no other customers in the database, this
        # specifies that the customer created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Customer.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => @customer.to_param, :customer => { "these" => "params" }}
      end

      it "assigns the requested customer as @customer" do
        put :update, {:id => @customer.to_param, :customer => valid_attributes}
        expect(assigns(:customer)).to eq(@customer)
      end

      it "redirects to the customer" do
        put :update, {:id => @customer.to_param, :customer => valid_attributes}
        expect(response).to redirect_to(@customer)
      end
    end

    describe "with invalid params" do
      it "assigns the customer as @customer" do
        # Trigger the behavior that occurs when invalid params are submitted
        Customer.any_instance.stub(:save).and_return(false)
        put :update, {:id => @customer.to_param, :customer => {  }}
        expect(assigns(:customer)).to eq(@customer)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Customer.any_instance.stub(:save).and_return(false)
        put :update, {:id => @customer.to_param, :customer => {  }}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested customer" do
      expect {
        delete :destroy, {:id => @customer.to_param}
      }.to change(Customer, :count).by(-1)
    end

    it "redirects to the customers list" do
      delete :destroy, {:id => @customer.to_param}
      expect(response).to redirect_to(customers_url)
    end
  end

end
