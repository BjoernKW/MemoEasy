class LocaleUtil
	def initialize(locale)
    @locale = locale
    @default_locale = I18n.locale

    set_locale
  end

	def set_locale
	  unless @locale.nil?
	    I18n.locale = @locale
	  end
	end

	def reset_locale
	  I18n.locale = @default_locale
	end
end
