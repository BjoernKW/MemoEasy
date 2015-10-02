class StaticContentController < ApplicationController
  before_filter :authenticate_user!, :except => [:contact, :terms]

  def contact
  end

  def terms
  end
end
