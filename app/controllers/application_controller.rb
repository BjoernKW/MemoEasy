class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/', :alert => exception.message
  end

  def after_sign_in_path_for(resource)
    case current_user.roles.first.name
      when 'admin'
        users_path
      else
        '/'
    end
  end
  
  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else 
      I18n.locale = extract_locale_from_accept_language_header
    end
  end

  def extract_locale_from_accept_language_header
    locale = 'de'

    if !Rails.env.test?
      if request.env['HTTP_ACCEPT_LANGUAGE']
        unless request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first == 'de'
          locale = 'en'
        end
      end
    else
      locale = 'en'
    end

    return locale
  end
end
