class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, @user, :message => ''
    @users = User.all
  end

  def show
    @company = Company.where(:name => request.subdomain).first
    @user = User.find(params[:id])
  end
  
  def update
    authorize! :update, @user, :message => I18n.t('auth.not_authorized_as_administrator')
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      redirect_to users_path, :notice => I18n.t('user.updated')
    else
      redirect_to users_path, :alert => I18n.t('unable_to_upate_user')
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => I18n.t('auth.not_authorized_as_administrator')
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => I18n.t('user.deleted')
    else
      redirect_to users_path, :notice => I18n.t('user.unable_to_delete_user')
    end
  end
end