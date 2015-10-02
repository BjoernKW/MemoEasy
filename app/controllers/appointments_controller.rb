class AppointmentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:public, :create, :thanks, :icalendar]
  before_filter :set_company_values, :except => [:thanks]
  
  # GET /appointments
  # GET /appointments.json
  # GET /appointments.ics
  def index
    load_calendar_data(current_user.company)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @appointments }
      format.ics {
        render :text => get_icalendar(@appointments)
      }
    end
  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show
    @appointment = Appointment.where(:id => params[:id], :company_id => current_user.company.id).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @appointment }
    end
  end

  # GET /appointments/new
  # GET /appointments/new.json
  def new
    initialize_appointment
    @available_time_slots = get_available_time_slots

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @appointment }
    end
  end

  # GET /appointments/1/edit
  def edit
    @appointment = Appointment.where(:id => params[:id], :company_id => current_user.company.id).first
    @available_time_slots = get_available_time_slots

    if request.xhr?
      render :partial => 'modal_form', :locals => { :appointment => @appointment }, :layout => false
    end
  end

  # POST /appointments
  # POST /appointments.json
  def create
    @appointment = Appointment.new(params[:appointment])
    if @appointment.starts_at.nil?
      @appointment.starts_at = get_start_date
    end
    @available_time_slots = get_available_time_slots

    unless current_user.nil?
      @appointment.user = current_user
      @appointment.company = current_user.company
    else
      @appointment.user = @appointment.company.users.first
    end

    unless params[:appointment][:customer_id].nil? || params[:appointment][:customer_id].blank?
      @appointment.customer = Customer.where(:id => params[:appointment][:customer_id], :company_id => @appointment.company.id).first
      if params[:appointment].has_key?(:from_public_page)
        unless @appointment.customer.nil?
          @appointment.customer.update_attributes(params[:appointment][:customer])
        end
      end
    else
      unless params[:appointment][:customer_attributes].nil? || params[:appointment][:customer_attributes].values.compact.empty?
        customer = Customer.where(
          Customer.arel_table[:email].eq(params[:appointment][:customer_attributes][:email]).or(
            Customer.arel_table[:mobile_phone].eq(params[:appointment][:customer_attributes][:mobile_phone])
          ),
          :company_id => @appointment.company.id
        ).first
        if customer.nil?
          customer = Customer.new(params[:appointment][:customer_attributes])
          customer.company = @appointment.company
          customer.save
        end
        @appointment.customer = customer
      end
    end

    unless params[:appointment][:service_id].nil? || params[:appointment][:service_id].blank?
      @appointment.service = Service.where(:id => params[:appointment][:service_id], :company_id => @appointment.company.id).first
    else
      unless params[:appointment][:service_attributes].nil? || params[:appointment][:service_attributes].values.compact.empty?
        service = Service.new(params[:appointment][:service_attributes])
        service.company = @appointment.company
        service.save
        @appointment.service = service
      end
    end

    unless params[:appointment][:staff_member_id].nil? || params[:appointment][:staff_member_id].blank?
      @appointment.staff_member = StaffMember.where(:id => params[:appointment][:staff_member_id], :company_id => @appointment.company.id).first
    else
      unless params[:appointment][:staff_member_attributes].nil? || params[:appointment][:staff_member_attributes].values.compact.empty?
        staff_member = StaffMember.new(params[:appointment][:staff_member_attributes])
        staff_member.company = @appointment.company
        staff_member.save
      end
      if params[:appointment][:show_new_staff_member] == 'false'
        staff_member = StaffMember.available_staff_members(@appointment.starts_at, @appointment.ends_at, current_user.company.id, nil).first
      end
      @appointment.staff_member = staff_member
    end

    set_appointment_dates

    respond_to do |format|
      if @appointment.save
        format.html {
          flash[:notice] = I18n.t(:successfully_created, :model_name => Appointment.model_name.human)
          unless @appointment.from_public_page
            redirect_to action: 'index'
          else
            redirect_to action: 'thanks'
          end
        }
        format.json {
          new_appointment = Appointment.new
          new_appointment.starts_at = get_start_date
          new_appointment.build_customer
          new_appointment.build_service
          new_appointment.build_staff_member

          render :json => {
            :calendar_partial => render_to_string(
              'appointments/_calendar',
              :formats => [:html],
              :layout => false,
              :locals => {
                :appointments => Appointment.where(:company_id => current_user.company.id).load,
                :date => Date.today
              }
            ),
            :modal_partial => render_to_string(
              'appointments/_modal_form',
              :formats => [:html],
              :layout => false,
              :locals => {
                :appointment => new_appointment
              }
            ),
            status: :created,
            location: @appointment
          }
        }
      else
        if @appointment.errors.has_key?(:no_permission) && !@appointment.from_public_page
          flash[:error] = I18n.t('appointments.too_many')
          @upgrade_plan = true
        end
        format.html {
          if @appointment.starts_at.blank?
            @appointment.starts_at = get_start_date
          end

          unless @appointment.from_public_page
            render action: "new"
          else
            render action: "public"
          end
        }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /appointments/1
  # PUT /appointments/1.json
  def update
    @appointment = Appointment.where(:id => params[:id], :company_id => current_user.company.id).first
    set_appointment_dates
    @available_time_slots = get_available_time_slots
    params[:appointment].delete(:starts_at)

    respond_to do |format|
      if @appointment.update_attributes(params[:appointment])
        flash[:notice] = I18n.t(:successfully_updated, :model_name => Appointment.model_name.human)
        format.html {
          redirect_to action: 'index'
        }
        format.json {
          render :json => {
            :calendar_partial => render_to_string(
              'appointments/_calendar',
              :formats => [:html],
              :layout => false,
              :locals => {
                :appointments => Appointment.where(:company_id => current_user.company.id).load,
                :date => Date.today
              }
            ),
            status: :created,
            location: @appointment
          }
        }
      else
        @appointment.errors.each do |name, error|
          flash[name] = error
        end

        format.html { render action: "edit" }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    @appointment = Appointment.where(:id => params[:id], :company_id => current_user.company.id).first
    @appointment.destroy

    respond_to do |format|
      format.html { redirect_to appointments_url }
      format.json { head :no_content }
    end
  end

  # GET /appointments/public
  def public
    unless @company.nil?
      initialize_appointment
      @appointment.from_public_page = true
      @appointment.show_new_staff_member = false
      @available_time_slots = get_available_time_slots

      if params.has_key?(:customer_id)
        @appointment.customer = Customer.where(:company_id => @company.id, :id => params[:customer_id]).limit(1).first
      else
        @appointment.customer = Customer.new
      end

      @slots = Slot.opening_hours.where(:company_id => @company.id).paginate(:page => params[:page])

      @address = @company.address
      @map_markers = "size:mid|color:red|#{@address}"
    end
  end

  # GET /appointments/thanks
  def thanks
  end

  # GET /appointments/show_day
  def show_day
    respond_to do |format|
      format.json {
        date = params[:date] ? Date.parse(params[:date]) : Date.today
        datetime = date.to_datetime

        render :json => {
          :appointments_today_partial => render_to_string(
            'appointments/_day',
            :formats => [:html],
            :layout => false,
            :locals => {
              :appointments_for_day => Appointment.where(
                "company_id = ? AND DATE(starts_at) = ?",
                current_user.company.id, date
              ).load,
              :date => date
            }
          ),
        }
      }
    end
  end

  # GET /appointments/icalendar
  # GET /appointments/icalendar.ics
  def icalendar
    load_calendar_data(Company.where(:ics_identifier => params[:id]).first)
    
    respond_to do |format|
      format.ics {
        render :text => get_icalendar(@appointments)
      }
    end
  end

  private
    def set_disabled_days_of_week(company)
      @disabled_days_of_week = [0, 1, 2, 3, 4, 5, 6]
      enabled_days_of_week = []
      @slots = Slot.opening_hours.where(:company_id => company.id).paginate(:page => params[:page])
      @slots.each do |slot|
        enabled_days_of_week.push(slot.weekday)
      end

      if @slots.length > 0
        @disabled_days_of_week -= enabled_days_of_week
      else
        @disabled_days_of_week = []
      end
    end

    def set_company_values
      unless current_user.nil?
        @company = current_user.company
      else
        @company = Company.where(:public_identifier => params[:id]).first
        if @company.nil? && !params[:appointment].nil?
          @company = Company.find(params[:appointment][:company_id])
        end
      end

      unless @company.nil?
        company_id = @company.id

        set_disabled_days_of_week(@company)

        @today = Date.today
        @not_available_days = (0 .. 6).to_a
        @next_available_day = nil
        @next_found = false

        @start_times = {
          0 => '00:00',
          1 => '00:00',
          2 => '00:00',
          3 => '00:00',
          4 => '00:00',
          5 => '00:00',
          6 => '00:00'
        }
        @end_times = {
          0 => '23:59',
          1 => '23:59',
          2 => '23:59',
          3 => '23:59',
          4 => '23:59',
          5 => '23:59',
          6 => '23:59'
        }

        slots = Slot.opening_hours.where(:company_id => company_id).paginate(:page => params[:page])
        slots.each do |slot|
          @start_times[slot.weekday] = "#{'%02d' % slot.starts_at_hour}:#{'%02d' % slot.starts_at_minute}"
          @end_times[slot.weekday] = "#{'%02d' % slot.ends_at_hour}:#{'%02d' % slot.ends_at_minute}"

          # gets next selectable weekday
          @not_available_days.delete(slot.weekday)
          if (slot.weekday > @today.wday || slot.weekday == 0) && !@next_found
            @next_available_day = slot.weekday
            if slot.weekday > @today.wday
              @next_found = true
            end
          end
        end

        # If no selectable weekday > the current weekday is found the first selectable
        # weekday is chosen, no matter if it comes before the current weekay.
        # This means that in that case the next selectable day in the next week will be
        # chosen.
        if !@next_found && slots.length > 0
          @next_available_day = slots[0].weekday
          @next_found = true
        end

        @selected_day = @today.wday
        if @not_available_days.include?(@today.wday) && @next_available_day
          @selected_day += @next_available_day - 1
        end
      end
    end

    # sets correct start date if current day is not selectable
    def get_start_date
      starts_at = @today.to_datetime
      if @not_available_days.include?(@today.wday) && @next_available_day
        advance_days = @next_available_day - @today.wday
        if advance_days < 0
          advance_days = 7 + advance_days
        end
        starts_at += advance_days
      end

      return starts_at
    end

    def initialize_appointment
      @appointment = Appointment.new
      @appointment.starts_at = get_start_date

      @appointment.build_service
      services = Service.where(:company_id => @company.id)
      if services.length == 1
        @appointment.service = services.first
      else
        @appointment.service.duration = 30
      end

      @appointment.build_staff_member
      staff_members = StaffMember.where(:company_id => @company.id)
      if staff_members.length == 1
        @appointment.staff_member = staff_members.first
      end

      @appointment.build_customer
      customers = Customer.where(:company_id => @company.id)
      if customers.length == 1
        @appointment.customer = customers.first
      end

      @appointment.show_new_customer = false
      @appointment.show_new_service = false
      @appointment.show_new_staff_member = false
    end

    def get_available_staff_members(appointment)
      StaffMember.available_staff_members(
        appointment.starts_at,
        appointment.starts_at.advance(
          :minutes => appointment.service.nil? ? 0 : appointment.service.duration),
        current_user.company.id,
        appointment.staff_member.nil? ? nil : appointment.staff_member.id
      )
    end

    def get_available_time_slots
      available_time_slots = []

      service = Service.where(:company_id => @company.id).first
      staff_member = @appointment.id.nil? ? nil : @appointment.staff_member

      unless staff_member.nil?
        appointments = Appointment.where(:company_id => @company.id, :staff_member_id => staff_member.id)
        available_time_slots = staff_member.available_time_slots(@appointment.starts_at.to_date, appointments, service)
      else
        available_time_slots = @company.available_time_slots_for_staff_members(@appointment.starts_at.to_date, service)
      end

      return available_time_slots
    end

    def set_appointment_dates
      unless @appointment.starts_at_time.nil?
        @appointment.starts_at = @appointment.starts_at_time
      end
      unless @appointment.starts_at.nil?
        @appointment.remind_at = @appointment.starts_at.advance(:seconds => -@appointment.company.reminder_interval)
        unless @appointment.service.nil?
          @appointment.ends_at = @appointment.starts_at.advance(:minutes => @appointment.service.duration)
        end
      end
    end

    def load_calendar_data(company)
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @appointments = []
      unless params[:staff_member_id]
        @appointments = Appointment.where(:company_id => company.id)
      else
        @appointments = Appointment.where(:company_id => company.id, :staff_member_id => params[:staff_member_id])
      end
      @appointments_for_day = Appointment.where(
        "company_id = ? AND DATE(starts_at) = ?",
        company.id, @date
      )
    end

    def get_icalendar(appointments)
      calendar = Icalendar::Calendar.new
      appointments.each do |appointment|
        calendar.add_event(appointment.to_ics)
      end
      calendar.publish

      return calendar.to_ical
    end
end
