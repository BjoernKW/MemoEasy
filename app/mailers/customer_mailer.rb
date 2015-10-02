class CustomerMailer < ActionMailer::Base
  default :from => ENV['MAIL_FROM_ADDRESS']

  def appointment_email(appointment, locale = nil)
    locale_util = LocaleUtil.new(locale)

    @appointment = appointment
    @public_url = "#{ENV['DOMAIN_PROTOCOL']}://#{ENV['DOMAIN_NAME']}#{public_path(:id => @appointment.company.public_identifier)}"

    attachments['appointment.ics'] = {
      :mime_type => 'text/calendar;method=REQUEST',
      :content => @appointment.to_ical
    }

  	mail(
  		:to => @appointment.customer.email,
  		:subject => I18n.t('emails.appointment.subject', :company => @appointment.company.name)
  	)

    locale_util.reset_locale
  end 
end
