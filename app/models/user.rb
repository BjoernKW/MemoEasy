require 'mail'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    r = EmailValidator.validate_email_address(value)
    record.errors[attribute] << (options[:message] || I18n.t('is_invalid')) unless r
  end

  def self.validate_email_address(email)
    r = true

    begin
      m = Mail::Address.new(email)
      
      # We must check that value contains a domain and that value is an email address
      r = m.domain && m.address == email
      # t = m.__send__(:tree)
      
      # We need to dig into treetop
      # A valid domain must have dot_atom_text elements size > 1
      # user@localhost is excluded
      # treetop must respond to domain
      # We exclude valid email values like <user@localhost.com>
      # Hence we use m.__send__(tree).domain
      # r &&= (t.domain.dot_atom_text.elements.size > 1)
    rescue Exception => e   
      r = false
    end

    return r
  end
end

class User < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActiveModel::Validations

  rolify

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :company

  attr_accessible :role_ids, :as => :admin
  attr_accessible :company_attributes, :country, :first_name, :last_name, :email, :unconfirmed_email,
                  :password, :password_confirmation, :remember_me

  accepts_nested_attributes_for :company

  attr_accessor :country

  before_destroy :cancel_subscription

  validates :company, :presence => true
  validates :email, :email => true, :uniqueness => true

  def name
    name = company.name
    unless first_name.nil? || last_name.nil?
      name = "#{first_name.capitalize} #{last_name.capitalize}"
    end
  end

  def update_plan(role)
    not_allowed = false
    number_of_calendars = StaffMember.where(:company_id => company.id).count
    if number_of_calendars > 1 && (role.name == 'starter' || role.name == 'silver') || number_of_calendars> 5 && (role.name == 'starter' || role.name == 'silver' || role.name == 'professional' || role.name == 'gold')
      not_allowed = true
    end

    unless not_allowed
      self.role_ids = []
      self.add_role(role.name)
    end
  end

  def cancel_subscription
  end

  def expire
    destroy
  end

  def abilities
    # default (i.e. Starter / Silver plan)
    abilities = {
      appointments_per_month: 100,
      calendars: 1,
      custom_logo: false,
      custom_email_templates: false
    }

    if has_role?(:professional) || has_role?(:gold)
      abilities = {
        appointments_per_month: 300,
        calendars: 5,
        custom_logo: true,
        custom_email_templates: false
      }
    end

    if has_role?(:business) || has_role?(:platinum)
      abilities = {
        appointments_per_month: 1000,
        calendars: 25,
        custom_logo: true,
        custom_email_templates: true
      }
    end

    if has_role? :admin
      abilities = {
        appointments_per_month: 100000,
        calendars: 100000,
        custom_logo: true,
        custom_email_templates: true
      }
    end

    return abilities
  end
end
