require 'csv'

class CustomerSetsController < ApplicationController
	before_filter :authenticate_user!

	# POST /customer_sets/create
  # POST /customer_sets/create.json
  def create
    @customer_set = CustomerSet.new

    unless params[:csv_file].nil?
      csv_file = params[:csv_file]
      records = CSV.parse(csv_file.read)
      
      records.each do |record|
        customer = Customer.new
        customer.company = Company.find(current_user.company.id)
        customer.first_name = record[0]
        customer.last_name = record[1]
        customer.email = record[2]
        customer.mobile_phone = record[3]
        customer.save

        @customer_set.customers << customer
      end
    else
      customer_inputs = params[:customers]
      
      customer_inputs.each do |customer_input|
        customer = Customer.new(customer_input)
        customer.company = Company.find(current_user.company.id)
        customer.save

        @customer_set.customers << customer
      end
    end

    respond_to do |format|
      if @customer_set.save
        format.html {
          flash[:notice] = I18n.t(:successfully_created, :model_name => CustomerSet.model_name.human)
          redirect_to controller: 'customers', action: 'multiple_new'
        }
        format.json {
          render :json => {
            status: :created,
            location: @customer_set
          }
        }
      else
        format.html {
          flash[:error] = I18n.t(:creation_failed, :model_name => CustomerSet.model_name.human)
          redirect_to controller: 'customers', action: 'multiple_new'
        }
        format.json { render json: @customer_set.errors, status: :unprocessable_entity }
      end
    end
  end
end
