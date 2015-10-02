class SlotsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /slots
  # GET /slots.json
  def index
    @slots = Slot.opening_hours.where(:company_id => current_user.company.id)
    @slots = @slots.sort { |a, b| a.cwday <=> b.cwday }

    @blockers = Slot.blockers.where(:company_id => current_user.company.id)
    @blockers = @blockers.sort { |a, b| a.cwday <=> b.cwday }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { slots: @slots, blockers: @blockers } }
    end
  end

  # GET /slots/1
  # GET /slots/1.json
  def show
    @slot = Slot.where(:id => params[:id], :company_id => current_user.company.id).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slot }
    end
  end

  # GET /slots/new
  # GET /slots/new.json
  def new
    @slot = Slot.new

    @slots = Slot.opening_hours.where(:company_id => current_user.company.id)
    @available_days = get_available_days(@slots)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @slot }
    end
  end

  # GET /slots/1/edit
  def edit
    @slot = Slot.where(:id => params[:id], :company_id => current_user.company.id).first
  end

  # POST /slots
  # POST /slots.json
  def create
    @slot = Slot.new(params[:slot])
    @slot.company = Company.find(current_user.company.id)

    unless @slot.starts_at_picker.nil?
      starts_at = @slot.starts_at_picker.split(':')
      @slot.starts_at_hour = starts_at.length > 0 ? starts_at[0] : 0
      @slot.starts_at_minute = starts_at.length > 1 ? starts_at[1] : 0
    end

    unless @slot.ends_at_picker.nil?
      ends_at = @slot.ends_at_picker.split(':')
      @slot.ends_at_hour = ends_at.length > 0 ? ends_at[0] : 0
      @slot.ends_at_minute = ends_at.length > 1 ? ends_at[1] : 0
    end
    
    respond_to do |format|
      if @slot.save
        format.html {
          flash[:notice] = I18n.t(:successfully_created, :model_name => Slot.model_name.human)
          redirect_to action: 'index'
        }
        format.json {
          slots = Slot.where(:company_id => current_user.company.id)
          available_days = get_available_days(slots)

          render :json => {
            :listPartial => render_to_string(
              'slots/_list',
              :formats => [:html],
              :layout => false,
              :locals => {
                :slots => slots
              }
            ),
            :modal_partial => render_to_string(
              'slots/_modal_form',
              :formats => [:html],
              :layout => false,
              :locals => {
                :slot => Slot.new,
                :available_days => available_days
              }
            ),
            status: :created,
            location: @slot
          }
        }
      else
        format.html { render action: "new" }
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /slots/1
  # PUT /slots/1.json
  def update
    @slot = Slot.where(:id => params[:id], :company_id => current_user.company.id).first

    unless params[:slot][:starts_at_picker].nil?
      starts_at = params[:slot][:starts_at_picker].split(':')
      @slot.starts_at_hour = starts_at.length > 0 ? starts_at[0] : 0
      @slot.starts_at_minute = starts_at.length > 1 ? starts_at[1] : 0
    end

    unless params[:slot][:ends_at_picker].nil?
      ends_at = params[:slot][:ends_at_picker].split(':')
      @slot.ends_at_hour = ends_at.length > 0 ? ends_at[0] : 0
      @slot.ends_at_minute = ends_at.length > 1 ? ends_at[1] : 0
    end

    respond_to do |format|
      if @slot.update_attributes(params[:slot])
        format.html {
          redirect_to @slot,
          notice: I18n.t(:successfully_updated, :model_name => Slot.model_name.human)
        }
        format.json { head :no_content }
      else
        @slot.errors.each do |name, error|
          flash[name] = error
        end
        format.html { render action: "edit" }
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.json
  def destroy
    @slot = Slot.where(:id => params[:id], :company_id => current_user.company.id).first
    @slot.destroy

    respond_to do |format|
      format.html { redirect_to slots_url }
      format.json { head :no_content }
    end
  end

  # GET /slots/list_available_weekdays.json
  def list_available_weekdays
    blocker = params[:blocker]

    slots = []
    unless blocker == 'true'
      slots = Slot.opening_hours.where(:company_id => current_user.company.id)
    else
      slots = Slot.blockers.where(:company_id => current_user.company.id)
    end

    available_days = get_available_days(slots)
    list_of_available_days = []
    available_days.each do |day|
      list_of_available_days.push({ id: day[1], name: day[0] })
    end

    puts list_of_available_days

    respond_to do |format|
      format.json { render json: list_of_available_days }
    end
  end

  private
    def get_available_days(slots)
      available_days = {}
      I18n.t('date.day_names').each_with_index.map do |e, i|
        available_days[e] = i
      end
      slots.each do |slot|
        available_days.delete(I18n.t('date.day_names')[slot.weekday])
      end

      return available_days
    end
end
