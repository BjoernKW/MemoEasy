require 'twilio-ruby'

class ReceiveTextMessageController < ApplicationController
	skip_before_filter :set_locale

	def index
		body = params['Body']
    from = params['From']

    customer = Customer.where(:mobile_phone => from.gsub(/\+/, '')).first
    
    unless customer.nil?
    	locale_util = LocaleUtil.new(customer.company.country.downcase)

	    begin
	    	client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
		    client.account.sms.messages.create(
		      :body => I18n.t('text_messages.account_confirmed', :company => customer.company.name),
		      :to => customer.mobile_phone_with_prefix,
		      :from => ENV['TWILIO_PHONE_NUMBER']
		    )
	    rescue Twilio::REST::RequestError
	    end

	    locale_util.reset_locale

	    customer.mobile_phone_confirmed_at, customer.confirmed_at = Time.now
	    customer.use_text_message = true
	    customer.save
	  end

    respond_to do |format|
      format.json { head :no_content }
    end
	end
end
