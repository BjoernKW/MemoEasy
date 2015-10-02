class UserMailer < ActionMailer::Base
  default :from => ENV['MAIL_FROM_ADDRESS']

  def expire_email(user)
    mail(:to => user.email, :subject => I18n.t('user_mailer.expire_email.subscription_cancelled', :domain_name => I18n.t('domain_name')))
  end
end
