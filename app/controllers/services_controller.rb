class ServicesController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /services
  # GET /services.json
  def index
    @services = Service.where(:company_id => current_user.company.id).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @services }
    end
  end

  # GET /services/1
  # GET /services/1.json
  def show
    @service = Service.where(:id => params[:id], :company_id => current_user.company.id).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service }
    end
  end

  # GET /services/new
  # GET /services/new.json
  def new
    @service = Service.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @service }
    end
  end

  # GET /services/1/edit
  def edit
    @service = Service.where(:id => params[:id], :company_id => current_user.company.id).first
  end

  # POST /services
  # POST /services.json
  def create
    @service = Service.new(params[:service])
    @service.company = Company.find(current_user.company.id)

    respond_to do |format|
      if @service.save
        format.html {
          flash[:notice] = I18n.t(:successfully_created, :model_name => Service.model_name.human)
          redirect_to action: 'index'
        }
        format.json {
          render :json => {
            :listPartial => render_to_string(
              'services/_list',
              :formats => [:html],
              :layout => false,
              :locals => {
                :services => Service.where(:company_id => current_user.company.id).paginate(:page => params[:page])
              }
            ),
            status: :created,
            location: @service
          }
        }
      else
        format.html { render action: "new" }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /services/1
  # PUT /services/1.json
  def update
    @service = Service.where(:id => params[:id], :company_id => current_user.company.id).first

    respond_to do |format|
      if @service.update_attributes(params[:service])
        format.html {
          redirect_to @service,
          notice: I18n.t(:successfully_updated, :model_name => Service.model_name.human)
        }
        format.json { head :no_content }
      else
        @service.errors.each do |name, error|
          flash[name] = error
        end
        format.html { render action: "edit" }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service = Service.where(:id => params[:id], :company_id => current_user.company.id).first
    @service.destroy

    respond_to do |format|
      format.html { redirect_to services_url }
      format.json { head :no_content }
    end
  end
end
