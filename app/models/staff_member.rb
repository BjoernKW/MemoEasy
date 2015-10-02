class StaffMember < ActiveRecord::Base
  belongs_to :company

  has_many :assignments, :dependent => :destroy
  has_many :slots, :through => :assignments
  has_many :appointments, :dependent => :destroy

  attr_accessible :name, :colour
  
  validates :company, :presence => true
  validates :name, :presence => true
  validates :colour, :presence => true
  validate :create_action_permitted

  self.per_page = 10

  def available_time_slots(date, appointments, service)
    if Rails.env.production?
      Rails.cache.fetch("/available_time_slots_for_staff_member/#{self.company.id}/#{service.nil? ? 'nil' : service.id}/#{self.id}/#{date.yday}") { available_time_slots!(date, appointments, service) }
    else
      available_time_slots!(date, appointments, service)
    end
  end

  def available_time_slots!(date, appointments, service)
    step = service.nil? ? 30 : service.duration
    available_time_slots = self.company.available_time_slots!(date, step)

    appointments.each do |appointment|
      available_time_slots.delete_if do |time_slot|
        if (time_slot + 1 * 60).between?(appointment.starts_at.to_time, appointment.ends_at.to_time) || (time_slot + (step - 1) * 60).between?(appointment.starts_at.to_time, appointment.ends_at.to_time)
          true
        end
      end
    end

    return available_time_slots
  end

  def self.available_staff_members(starts_at, ends_at, company_id, staff_member_id)
    StaffMember.find_by_sql(["
      SELECT * FROM staff_members WHERE id NOT IN (
        SELECT s.id FROM staff_members s, appointments a
        WHERE a.staff_member_id = s.id
        AND (
          (
            a.starts_at < :ends_at
            AND a.ends_at > :ends_at
          )
          OR (
            a.starts_at < :starts_at
            AND a.ends_at > :starts_at
          )
          OR (
            a.starts_at = :starts_at
            AND a.ends_at = :ends_at
          )
        ) AND s.id != :staff_member_id
      ) AND company_id = :company_id
    ", { :starts_at => starts_at, :ends_at => ends_at, :company_id => company_id, :staff_member_id => staff_member_id }])
  end

  def self.staff_member_list_for_appointment(appointment, company_id)
    staff_members = []

    if appointment.starts_at.nil?
      staff_members = StaffMember.where(:company_id => company_id).load
    else
      staff_members = StaffMember.available_staff_members(
        appointment.starts_at,
        appointment.starts_at.advance(:minutes => appointment.service.nil? ? 0 : appointment.service.duration),
        company_id,
        appointment.staff_member.nil? ? nil : appointment.staff_member.id
      )
    end

    return staff_members
  end

  def create_action_permitted
    unless Rails.env.test?
      if new_record?
        number_of_allowed_calendars = company.users.first.abilities[:calendars]
        number_of_calendars = StaffMember.where(:company_id => company.id).count
        if number_of_allowed_calendars <= number_of_calendars
          errors[:no_permission] << (I18n.t('staff_members.too_many'))
        end
      end
    end
  end
end
