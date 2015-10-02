require 'rest_client'
require 'twilio-ruby'

class Customer < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :company

  has_many :appointments, :dependent => :destroy

  attr_accessible :email, :first_name, :last_name, :mobile_phone,
                  :use_html_email, :use_text_email, :use_text_message,
                  :confirmation_token, :confirmed_at, :confirmed_sent_at,
                  :email_confirmation_token, :mobile_phone_confirmation_token,
                  :email_confirmed_at, :mobile_phone_confirmed_at
  
  phony_normalize :mobile_phone, :default_country_code => 'DE'

  validates :company, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :confirmation_token, :presence => true
  validates :email_confirmation_token, :presence => true
  validates :mobile_phone_confirmation_token, :presence => true
  validates :mobile_phone, :phony_plausible => true
  validate :email_or_mobile_phone_is_present

  before_validation :set_confirmation_token

  self.per_page = 10

  before_save :send_customer_confirmation_as_email, if: 'new_record? && email_confirmed_at.blank?'
  before_save :send_customer_confirmation_as_text_message, if: 'new_record? && mobile_phone_confirmed_at.blank?'

  def name
  	"#{self.first_name} #{self.last_name}"
  end

  def mobile_phone_with_prefix
    "+#{mobile_phone}"
  end

  def available_days()
    self.find_by_sql(["
      SELECT * FROM companies WHERE id O :company_id NOT IN
    ", { :company_id => self.id }])
  end

  def send_customer_link
    unless Rails.env.test?
      public_url = "#{ENV['DOMAIN_PROTOCOL']}://#{ENV['DOMAIN_NAME']}#{public_path(:id => self.company.public_identifier, :customer_id => self.id)}"
      
      RestClient.post "#{MemoEasy::Application.config.mailgun_api_url}/messages", 
        :from => ENV['MAIL_FROM_ADDRESS'],
        :to => self.email,
        :subject => I18n.t('emails.customer_link.subject', :company => self.company.name),
        :text => I18n.t('emails.customer_link.text_body', :customer => "#{self.name}", :public_url => public_url),
        :html => I18n.t('emails.customer_link.html_body', :customer => "#{self.name}", :public_url => public_url)
    end
  end

  def send_customer_confirmation_as_email
    unless Rails.env.test?
      if self.email.present?
        confirmation_url = "#{ENV['DOMAIN_PROTOCOL']}://#{ENV['DOMAIN_NAME']}#{confirmation_customer_path(:id => self.email_confirmation_token)}"
        
        RestClient.post "#{MemoEasy::Application.config.mailgun_api_url}/messages", 
          :from => ENV['MAIL_FROM_ADDRESS'],
          :to => self.email,
          :subject => I18n.t('emails.customer_confirmation.subject', :company => self.company.name),
          :text => I18n.t('emails.customer_confirmation.text_body', :customer => "#{self.name}", :confirmation_url => confirmation_url),
          :html => I18n.t('emails.customer_confirmation.html_body', :customer => "#{self.name}", :confirmation_url => confirmation_url)
      
        self.confirmation_sent_at = Time.now
      end
    end
  end

  def send_customer_confirmation_as_text_message
    unless Rails.env.test?
      if self.mobile_phone.present?
        begin
          client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
          client.account.sms.messages.create(
            :body => I18n.t('text_messages.customer_confirmation', :company => self.company.name),
            :to => self.mobile_phone_with_prefix,
            :from => ENV['TWILIO_PHONE_NUMBER']
          )

          self.confirmation_sent_at = Time.now
        rescue Twilio::REST::RequestError
        end
      end
    end
  end

  def email_or_mobile_phone_is_present
    if email.blank? && mobile_phone.blank?
      errors[:email] << (I18n.t('customers.messaging_details'))
      errors[:mobile_phone] << (I18n.t('customers.messaging_details'))
    else
      unless email.blank?
        email_valid = EmailValidator.validate_email_address(email)

        errors[:email] << I18n.t('is_invalid') unless email_valid
      end
    end
  end

  private
    def set_confirmation_token
      if self.confirmation_token.nil?
        self.confirmation_token = Digest::SHA2.hexdigest(self.name + rand.to_s + MemoEasy::Application.config.secret_key_base)
      end

      if self.email_confirmation_token.nil?
        self.email_confirmation_token = Digest::SHA2.hexdigest(self.email + rand.to_s + MemoEasy::Application.config.secret_key_base)
      end

      if self.mobile_phone_confirmation_token.nil?
        self.mobile_phone_confirmation_token = Digest::SHA2.hexdigest((self.mobile_phone.nil? ? self.name : self.mobile_phone) + rand.to_s + MemoEasy::Application.config.secret_key_base)
      end
    end
end
