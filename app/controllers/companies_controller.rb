class CompaniesController < ApplicationController
	before_filter :authenticate_user!, :except => [:list_available_days]
  
  # GET /companies
  # GET /companies.json
  def index
    @company = Company.find(current_user.company.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @companies }
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Company.find(current_user.company.id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.json
  def new
    @company = Company.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Company.find(current_user.company.id)
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(params[:company])

    respond_to do |format|
      if @company.save
        format.html {
          redirect_to '/',
          notice: I18n.t(:successfully_created, :model_name => Company.model_name.human)
        }
        format.json { render json: @company, status: :created, location: @company }
      else
        format.html { render action: "new" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /companies/1
  # PUT /companies/1.json
  def update
    @company = Company.find(current_user.company.id)

    respond_to do |format|
      @company.assign_attributes(params[:company])
      @company.reminder_interval = params[:company][:reminder_interval].to_i * 60 * 60
      if @company.save
        current_user.country = @company.country
        current_user.save
        
        format.html {
          redirect_to '/',
          notice: I18n.t(:successfully_updated, :model_name => Company.model_name.human)
        }
        format.json { head :no_content }
      else
        @company.errors.each do |name, error|
          flash[name] = error
        end
        format.html { render action: "edit" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = Company.find(current_user.company.id)
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end

  # GET /companies/list_available_days.json
  def list_available_days
    company = Company.find(params[:company_id])
    if params.has_key?(:service_id) && !params[:service_id].blank?
      service = Service.find(params[:service_id])
    end
    if params.has_key?(:staff_member_id) && !params[:staff_member_id].blank?
      staff_member = StaffMember.find(params[:staff_member_id])
    end
    available_days = company.available_days(params[:year], params[:month], service, staff_member)

    respond_to do |format|
      format.json { render json: available_days }
    end
  end
end
