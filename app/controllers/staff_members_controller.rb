class StaffMembersController < ApplicationController
  before_filter :authenticate_user!, :except => [:list_available, :list_available_time_slots]

  # GET /staff_members
  # GET /staff_members.json
  def index
    @staff_members = StaffMember.where(:company_id => current_user.company.id).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @staff_members }
    end
  end

  # GET /staff_members/1
  # GET /staff_members/1.json
  def show
    @staff_member = StaffMember.where(:id => params[:id], :company_id => current_user.company.id).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @staff_member }
    end
  end

  # GET /slots/list_available_time_slots.json
  def list_available_time_slots
    available_time_slots = []

    company = Company.find(params[:company_id])
    service = Service.find(params[:service_id])
    staff_member = params[:staff_member_id].nil? || params[:staff_member_id].blank? ? nil : StaffMember.find(params[:staff_member_id])
    if staff_member
      appointments = Appointment.where(:company_id => company.id, :staff_member_id => staff_member.id)
      available_time_slots = staff_member.available_time_slots(Date.parse(params[:date]), appointments, service)
    else
      available_time_slots = company.available_time_slots_for_staff_members(Date.parse(params[:date]), service)
    end

    respond_to do |format|
      format.json { render json: available_time_slots }
    end
  end

  # GET /slots/list_available.json
  def list_available
    company = Company.find(params[:company_id])
    staff_member = !(params[:staff_member_id].nil? || params[:staff_member_id].blank?) ? StaffMember.find(params[:staff_member_id]) : nil

    starts_at = DateTime.parse(params[:starts_at])
    starts_at = starts_at.change({
      :hour => params[:starts_at_hour].to_i,
      :min => params[:starts_at_minute].to_i,
    }) unless params[:starts_at_hour].nil? || params[:starts_at_minute].nil?
    service = Service.where(:id => params[:service_id], :company_id => params[:company_id]).first
    ends_at = starts_at.advance(:minutes => service.nil? ? 0 : service.duration)

    staff_members = StaffMember.available_staff_members(
      starts_at,
      ends_at,
      company.id,
      staff_member.nil? ? nil : staff_member.id
    )

    respond_to do |format|
      format.json { render json: staff_members }
    end
  end

  # GET /staff_members/new
  # GET /staff_members/new.json
  def new
    @staff_member = StaffMember.new
    @last_staff_member = StaffMember.where(:company_id => current_user.company.id).order('id DESC').limit(1).first
    @staff_member.colour = MemoEasy::Application.config.default_colours[@last_staff_member.nil? ? 0 : @last_staff_member.id % MemoEasy::Application.config.default_colours.length]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @staff_member }
    end
  end

  # GET /staff_members/1/edit
  def edit
    @staff_member = StaffMember.where(:id => params[:id], :company_id => current_user.company.id).first
  end

  # POST /staff_members
  # POST /staff_members.json
  def create
    @staff_member = StaffMember.new(params[:staff_member])
    @staff_member.company = Company.find(current_user.company.id)

    respond_to do |format|
      if @staff_member.save
        format.html {
          flash[:notice] = I18n.t(:successfully_created, :model_name => StaffMember.model_name.human)
          redirect_to action: 'index'
        }
        format.json {
          render :json => {
            :listPartial => render_to_string(
              'staff_members/_list',
              :formats => [:html],
              :layout => false,
              :locals => {
                :staff_members => StaffMember.where(:company_id => current_user.company.id).paginate(:page => params[:page])
              }
            ),
            status: :created,
            location: @staff_member
          }
        }
      else
        if @staff_member.errors.has_key?(:no_permission)
          flash[:error] = I18n.t('staff_members.too_many')
          @upgrade_plan = true
        end
        format.html { render action: "new" }
        format.json { render json: @staff_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /staff_members/1
  # PUT /staff_members/1.json
  def update
    @staff_member = StaffMember.where(:id => params[:id], :company_id => current_user.company.id).first

    respond_to do |format|
      if @staff_member.update_attributes(params[:staff_member])
        format.html {
          redirect_to @staff_member,
          notice: I18n.t(:successfully_updated, :model_name => StaffMember.model_name.human)
        }
        format.json { head :no_content }
      else
        @staff_member.errors.each do |name, error|
          flash[name] = error
        end
        format.html { render action: "edit" }
        format.json { render json: @staff_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_members/1
  # DELETE /staff_members/1.json
  def destroy
    @staff_member = StaffMember.where(:id => params[:id], :company_id => current_user.company.id).first
    @staff_member.destroy

    respond_to do |format|
      format.html { redirect_to staff_members_url }
      format.json { head :no_content }
    end
  end
end
