class CustomersController < ApplicationController
  before_filter :authenticate_user!, :except => [:confirmation]
  
  # GET /customers
  # GET /customers.json
  def index
    @customers = Customer.where(:company_id => current_user.company.id).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @customers }
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @customer = Customer.where(:id => params[:id], :company_id => current_user.company.id).first
    @appointments = Appointment.where(:company_id => current_user.company.id, :customer_id => @customer.id).order('starts_at DESC').paginate(:page => params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.json
  def new
    @customer = Customer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/multiple_new
  # GET /customers/multiple_new.json
  def multiple_new
    @customer_set = CustomerSet.new

    respond_to do |format|
      format.html # multiple_new.html.erb
      format.json { render json: @customer_set }
    end
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.where(:id => params[:id], :company_id => current_user.company.id).first
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(params[:customer])
    @customer.company = Company.find(current_user.company.id)

    respond_to do |format|
      if @customer.save
        format.html {
          flash[:notice] = I18n.t(:successfully_created, :model_name => Customer.model_name.human)
          redirect_to action: 'index'
        }
        format.json {
          render :json => {
            :listPartial => render_to_string(
              'customers/_list',
              :formats => [:html],
              :layout => false,
              :locals => {
                :customers => Customer.where(:company_id => current_user.company.id).paginate(:page => params[:page])
              }
            ),
            status: :created,
            location: @customer
          }
        }
      else
        format.html { render action: "new" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.json
  def update
    @customer = Customer.where(:id => params[:id], :company_id => current_user.company.id).first

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.html {
          redirect_to @customer,
          notice: I18n.t(:successfully_updated, :model_name => Customer.model_name.human)
        }
        format.json { head :no_content }
      else
        @customer.errors.each do |name, error|
          flash[name] = error
        end
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer = Customer.where(:id => params[:id], :company_id => current_user.company.id).first
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_url }
      format.json { head :no_content }
    end
  end

  def customer_link
    render :partial => 'customer_link', :locals => { :customer => Customer.where(:id => params[:id], :company_id => current_user.company.id).limit(1).first }, :layout => false
  end

  def send_customer_link
    @customer = Customer.where(:id => params[:id], :company_id => current_user.company.id).first
    @customer.send_customer_link
    
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def confirmation
    @customer = Customer.where(:email_confirmation_token => params[:id]).first
    
    unless @customer.nil?
      @customer.email_confirmed_at, @customer.confirmed_at = Time.now
      @customer.use_html_email = true
      @customer.use_text_email = true
      @customer.save
    end
  end
end
