require 'rest_client'
require 'twilio-ruby'

class Appointment < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :company
  belongs_to :user
  belongs_to :customer
  belongs_to :service
  belongs_to :staff_member

  default_scope { order('starts_at ASC') }

  attr_accessible :starts_at_picker, :starts_at, :ends_at, :remind_at, :starts_at_time,
                  :use_html_email, :use_text_email, :use_text_message, :notes,
                  :customer_id, :service_id, :staff_member_id,
                  :customer_attributes, :service_attributes, :staff_member_attributes,
                  :customer, :service, :staff_member,
                  :show_new_customer, :show_new_service, :show_new_staff_member,
                  :company_id, :from_public_page, :repeat_in_days

  validates :company, :presence => true
  validates :customer, :presence => true
  validates :service, :presence => true
  validates :staff_member, :presence => true
  validates :starts_at, :presence => true
  validates :ends_at, :presence => true
  validate :create_action_permitted

  accepts_nested_attributes_for :customer
  accepts_nested_attributes_for :service
  accepts_nested_attributes_for :staff_member

  attr_accessor :starts_at_picker
  attr_accessor :starts_at_time

  attr_accessor :show_new_customer
  attr_accessor :show_new_service
  attr_accessor :show_new_staff_member

  attr_accessor :from_public_page

  self.per_page = 10

  before_save :send_reminder_as_email
  before_save :send_reminder_as_text_message
  after_save :send_appointment

  before_update :remove_reminder_email_from_queue, if: :starts_at_changed?
  before_update :remove_text_message_from_queue, if: :starts_at_changed?

  before_update :send_appointment, if: :starts_at_changed?
  before_update :send_reminder_as_email, if: :starts_at_changed?
  before_update :send_reminder_as_text_message, if: :starts_at_changed?

  def send_reminder_as_text_message
    unless Rails.env.test?
      unless self.customer.mobile_phone_confirmed_at.blank?
        run_at = self.starts_at - 2.hours
        run_at = 2.minutes.from_now if Rails.env.development?

        body = I18n.t('text_messages.reminder', :company => self.company.name, :starts_at => I18n.l(self.starts_at), :duration => self.service.duration)

        text_message_job = Delayed::Job.enqueue(
          ::SendReminderAsTextMessageJob.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'], ENV['TWILIO_PHONE_NUMBER'], self.customer.mobile_phone_with_prefix, body),
          :run_at => run_at
        )
        self.text_message_job_id = text_message_job.id
      end
    end
  end

  def send_reminder_as_email
    unless Rails.env.test?
      unless self.customer.email_confirmed_at.blank?
        run_at = self.starts_at - self.company.reminder_interval_in_hours.hours
        run_at = 5.minutes.from_now if Rails.env.development?

        api_url = "#{MemoEasy::Application.config.mailgun_api_url}/messages"
        public_url = "#{ENV['DOMAIN_PROTOCOL']}://#{ENV['DOMAIN_NAME']}#{public_path(:id => self.company.public_identifier)}"

        subject = I18n.t('emails.reminder.subject', :company => self.company.name)
        text_body =  I18n.t('emails.reminder.text_body', :customer => "#{self.customer.first_name} #{self.customer.last_name}", :company => self.company.name, :public_url => public_url, :starts_at => I18n.l(self.starts_at), :duration => self.service.duration, :staff_member => self.staff_member.name)
        html_body = I18n.t('emails.reminder.html_body', :customer => "#{self.customer.first_name} #{self.customer.last_name}", :company => self.company.name, :public_url => public_url, :starts_at => I18n.l(self.starts_at), :duration => self.service.duration, :staff_member => self.staff_member.name)

        reminder_email_job = Delayed::Job.enqueue(
          ::SendReminderAsEmailJob.new(api_url, ENV['MAIL_FROM_ADDRESS'], self.customer.email, subject, text_body, html_body),
          :run_at => run_at
        )
        self.reminder_email_job_id = reminder_email_job.id
      end
    end
  end

  def create_next_appointment
    new_appointment = self.dup

    interval_until_next_appointment = new_appointment.repeat_in_days * 24
    new_appointment.starts_at += interval_until_next_appointment.hours
    new_appointment.ends_at += interval_until_next_appointment.hours
    new_appointment.remind_at += interval_until_next_appointment.hours
    
    new_appointment.save
  end

  def send_appointment
    unless Rails.env.test?
      unless self.customer.email_confirmed_at.blank?
        CustomerMailer.delay.appointment_email(self, I18n.locale)
      end
      if self.company.send_appointment_confirmation
        CompanyMailer.delay.appointment_confirmation_email(self, I18n.locale)
      end
    end
  end

  def to_ics
    event = Icalendar::Event.new
    
    event.start = self.starts_at.strftime("%Y%m%dT%H%M%S")
    event.end = self.ends_at.strftime("%Y%m%dT%H%M%S")
    event.summary = self.service.name
    event.description = "#{self.service.name}, #{self.company.name}"
    event.location = self.company.address
    event.klass = "PUBLIC"
    event.created = self.created_at
    event.last_modified = self.updated_at
    event.uid = event.url = "#{ENV['DOMAIN_PROTOCOL']}://#{ENV['DOMAIN_NAME']}#{public_path(:id => self.company.public_identifier, :appointment_id => self.id)}"

    return event
  end

  def to_ical
    calendar = Icalendar::Calendar.new

    calendar.add_event(self.to_ics)
    calendar.publish

    return calendar.to_ical
  end

  def create_action_permitted
    unless Rails.env.test?
      if new_record?
        extracted_month = "EXTRACT(MONTH FROM created_at)"
        if Rails.env.development?
          extracted_month = "strftime('%m', created_at) + 0"
        end

        number_of_allowed_appointments_per_month = company.users.first.abilities[:appointments_per_month]
        number_of_appointments_for_current_month = Appointment.where(
          "company_id = ? AND #{extracted_month} = ?",
          company.id, Date.today.mon
        ).count
        if number_of_allowed_appointments_per_month <= number_of_appointments_for_current_month
          errors[:no_permission] << (I18n.t('appointments.too_many'))
        end
      end
    end
  end

  private
    def date_has_changed?
      self.starts_at_changed?
    end

    def remove_reminder_email_from_queue
      Delayed::Job.find(self.reminder_email_job_id).destroy unless self.reminder_email_job_id.nil?
    end

    def remove_text_message_from_queue
      Delayed::Job.find(self.text_message_job_id).destroy unless self.text_message_job_id.nil?
    end
end

class SendReminderAsTextMessageJob < Struct.new(:twilio_account_sid, :twilio_auth_token, :from, :to, :body)
  def perform
    begin
      client = Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token)
      client.account.sms.messages.create(
        :body => body,
        :to => to,
        :from => from
      )
    rescue Twilio::REST::RequestError
    end    
  end
end

class SendReminderAsEmailJob < Struct.new(:api_url, :from, :to, :subject, :text_body, :html_body)
  def perform
    RestClient.post api_url, 
      :from => from,
      :to => to,
      :subject => subject,
      :text => text_body,
      :html => html_body
  end
end
