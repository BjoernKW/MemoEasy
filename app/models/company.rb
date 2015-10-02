require 'digest/sha2'
require 'net/http'

# Thanks Ilya! http://www.igvita.com/2006/09/07/validating-url-in-ruby-on-rails/
# Original credits: http://blog.inquirylabs.com/2006/04/13/simple-uri-validation/
# HTTP Codes: http://www.ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTPResponse.html
class UriValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value.blank?
      raise(ArgumentError, "A regular expression must be supplied as the :format option of the options hash") unless options[:format].nil? or options[:format].is_a?(Regexp)
      configuration = { :message => "is invalid or not responding", :format => URI::regexp(%w(http https)) }
      configuration.update(options)
      
      if value =~ configuration[:format]
        begin # check header response
          case Net::HTTP.get_response(URI.parse(value))
            when Net::HTTPSuccess then true
            else object.errors.add(attribute, configuration[:message]) and false
          end
        rescue # Recover on DNS failures..
          object.errors.add(attribute, configuration[:message]) and false
        end
      else
        object.errors.add(attribute, configuration[:message]) and false
      end
    end
  end
end

class Company < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :users, :dependent => :destroy
  has_many :appointments, :dependent => :destroy
  has_many :customers, :dependent => :destroy
  has_many :slots, :dependent => :destroy
  has_many :services, :dependent => :destroy
  has_many :staff_members, :dependent => :destroy

  attr_accessible :bank_id, :bank_account_number, :bank_name,
                  :name, :public_identifier, :ics_identifier, :company_register_id,
                  :use_html_email, :use_text_email, :use_text_message, :send_appointment_confirmation,
                  :reminder_interval, :reminder_interval_in_minutes, :reminder_interval_in_hours,
                  :street_address, :postal_code, :city, :country,
                  :phone_number, :vat_id, :website_url, :logo_url

  validates :name, :presence => true
  validates :street_address, :presence => true
  validates :postal_code, :presence => true
  validates :city, :presence => true
  validates :public_identifier, :presence => true
  validates :ics_identifier, :presence => true
  validates_length_of :name, maximum: 32, message: I18n.t('validations.exceeds_maximum_of_32_characters')
  validates_exclusion_of :name, in: ['www', 'mail', 'ftp'], message: I18n.t('validations.name.not_available')
  validates :reminder_interval, :presence => true
  validates :website_url, :uri => true
  validates :logo_url, :uri => true

  before_validation :set_public_identifier
  before_validation :set_ics_identifier

  self.per_page = 10

  def available_time_slots(date, step)
    if Rails.env.production?
      Rails.cache.fetch("/available_time_slots_for_company/#{self.id}/#{date.yday}/#{step}") { available_time_slots!(date, step) }
    else
      available_time_slots!(date, step)
    end
  end

  def available_time_slots!(date, step)
    available_time_slots = []

    number_of_slots_per_hour = 60 / step
    minutes = []
    number_of_slots_per_hour.times do |x|
      minutes.push(x * step)
    end

    slot = Slot.where(:company_id => self.id, :weekday => date.cwday == 7 ? 0 : date.cwday).first
    blockers = Slot.blockers.where(:company_id => self.id, :weekday => date.cwday == 7 ? 0 : date.cwday)

    unless slot.nil?
      hours = *(slot.starts_at_hour .. slot.ends_at_hour)

      hours.each_with_index do |hour, i|
        minutes.each do |minute|
          unless (i == 0 && minute < slot.starts_at_minute) || (i == hours.length - 1 && minute >= slot.ends_at_minute)
            available_time_slots.push(
              Time.new(
                date.year,
                date.mon,
                date.day,
                hour,
                minute
              )
            )
          end
        end
      end
    end

    blockers.each do |blocker|
      blocker_starts_at = Time.new(
        date.year,
        date.mon,
        date.day,
        blocker.starts_at_hour,
        blocker.starts_at_minute
      )
      blocker_ends_at = Time.new(
        date.year,
        date.mon,
        date.day,
        blocker.ends_at_hour,
        blocker.ends_at_minute
      )

      available_time_slots.delete_if do |time_slot|
        if (time_slot + 1 * 60).between?(blocker_starts_at, blocker_ends_at) || (time_slot + (step - 1) * 60).between?(blocker_starts_at, blocker_ends_at)
          true
        end
      end
    end

    return available_time_slots.sort
  end

  def available_time_slots_for_staff_members(date, service)
    if Rails.env.production?
      Rails.cache.fetch("/available_time_slots_for_staff_members/#{self.id}/#{date.yday}") { available_time_slots_for_staff_members!(date, service)}
    else
      available_time_slots_for_staff_members!(date, service)
    end
  end

  def available_time_slots_for_staff_members!(date, service)
    selected_service = service.nil? ? Service.where(:company_id => self.id).first : service
    step = selected_service.nil? ? 30 : selected_service.duration

    available_time_slots = self.available_time_slots(date, step)
    available_time_slots_with_count = []
    available_time_slots.each do |time_slot|
      available_time_slots_with_count.push({ :time => time_slot, :count => staff_members.length })
    end

    self.staff_members.each do |staff_member|
      appointments = Appointment.where(:company_id => self.id, :staff_member_id => staff_member.id)
      appointments.each do |appointment|
        available_time_slots_with_count.each do |time_slot|
          if (time_slot[:time] + 1 * 60).between?(appointment.starts_at.to_time, appointment.ends_at.to_time) || (time_slot[:time] + (step - 1) * 60).between?(appointment.starts_at.to_time, appointment.ends_at.to_time)
            time_slot[:count] -= 1
          end
        end
      end
    end

    available_time_slots_with_count.delete_if do |time_slot|
      if time_slot[:count] <= 0
        true
      end
    end

    available_time_slots = available_time_slots_with_count.map { |time_slot| time_slot[:time] }

    return available_time_slots.sort
  end

  def all_available_time_slots(date, appointments, service)
    if Rails.env.production?
      Rails.cache.fetch("/all_available_time_slots/#{self.id}/#{service.id}/#{date.yday}") { all_available_time_slots!(date, appointments, service) }
    else
      all_available_time_slots!(date, appointments, service)
    end
  end

  def all_available_time_slots!(date, appointments, service)
    selected_service = service.nil? ? Service.where(:company_id => self.id).first : service
    step = selected_service.nil? ? 30 : selected_service.duration

    available_time_slots = self.available_time_slots!(date, step)

    appointments.each do |appointment|
      available_time_slots.delete_if do |time_slot|
        if (time_slot + 1 * 60).between?(appointment.starts_at.to_time, appointment.ends_at.to_time) || (time_slot + (step - 1) * 60).between?(appointment.starts_at.to_time, appointment.ends_at.to_time)
          true
        end
      end
    end

    return available_time_slots
  end

  def available_days(year, month, service, staff_member)
    if Rails.env.production?
      Rails.cache.fetch("/available_days/#{self.id}/#{year}/#{month}") { available_days!(year, month, service, staff_member) }
    else
      available_days!(year, month, service, staff_member)
    end
  end

  def available_days!(year, month, service, staff_member)
    available_days = {}
    weeks = []

    unless year.nil? || month.nil? || year.blank? || month.blank?
      first_day_of_month = Date.new(year.to_i, month.to_i, 1)
      last_day_of_month = first_day_of_month.end_of_month
      weekday = Date.new(year.to_i, month.to_i, first_day_of_month.day).beginning_of_week

      # reset weekday to first day of the year if first week of the year
      if weekday.month == 12 && month.to_i == 1
        weekday = Date.new(year.to_i, month.to_i, first_day_of_month.day).beginning_of_year
      end

      weeks = (first_day_of_month.cweek .. (last_day_of_month.cweek > 1 ? last_day_of_month.cweek : 53)) # use cweek value 53 for last week of the year
      slots = Slot.where(:company_id => self.id)
      slots.sort! { |a, b| a.cwday <=> b.cwday }
    end

    weeks.each do |week|
      previous_slot = nil

      slots.each do |slot|
        if slot.cwday > weekday.cwday
          weekday += slot.cwday - (previous_slot.nil? ? 0 : previous_slot.cwday)
          if weekday.cwday > slot.cwday
            weekday -= weekday.cwday - slot.cwday
          end
        end

        if slot.cwday >= weekday.cwday
          if weekday.month == first_day_of_month.month
            available_time = slot.duration_in_minutes
            base_time = available_time
            available_time_slots = []

            unless staff_member.nil?
              appointments = Appointment.where(:company_id => self.id, :staff_member_id => staff_member.id, :starts_at => weekday.beginning_of_day .. weekday.end_of_day)
              available_time_slots = staff_member.available_time_slots(weekday, appointments, service)
            else
              appointments = Appointment.where(:company_id => self.id, :starts_at => weekday.beginning_of_day .. weekday.end_of_day)
              available_time_slots = self.all_available_time_slots(weekday, appointments, service)
            end

            if available_time_slots.length > 2
              available_days[weekday.day] = 'available'
            elsif available_time_slots.length > 0
              available_days[weekday.day] = 'few_left'
            end
          end

          if weekday.month > first_day_of_month.month
            break
          end
        end

        previous_slot = slot
      end

      weekday = weekday.next_week
    end

    return available_days
  end

  def address
    "#{self.street_address.nil? ? '' : self.street_address + ', '}#{self.postal_code.nil? ? '' : self.postal_code + ', '}#{self.city.nil? ? '' : self.city + ', '}#{self.country.blank? ? '' :I18n.t(self.country, :scope => :countries)}"
  end

  def reminder_interval_in_hours
    (self.reminder_interval_in_minutes / 60).round
  end

  def reminder_interval_in_minutes
    (self.reminder_interval / 60).round
  end

  def self.get_default_reminder_interval
    60 * 60 * 24
  end

  private
    def set_public_identifier
      if self.public_identifier.nil?
        self.public_identifier = Digest::SHA2.hexdigest(self.name + rand.to_s + MemoEasy::Application.config.secret_key_base)
      end
    end

    def set_ics_identifier
      if self.ics_identifier.nil?
        self.ics_identifier = Digest::SHA2.hexdigest(self.name + self.public_identifier + rand.to_s + MemoEasy::Application.config.secret_key_base)
      end
    end
end
