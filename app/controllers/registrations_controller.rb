class RegistrationsController < Devise::RegistrationsController

  def new
    @plan = params[:plan]
    if @plan
      super
    else
      redirect_to '/', :notice => I18n.t('plans.select_plan')
    end
  end

  def update
    super

    resource.update_attributes(
      :first_name => params[:user][:first_name],
      :last_name => params[:user][:last_name],
    )
  end

  def update_plan
    @user = current_user
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    if @user.update_plan(role)
      redirect_to edit_user_registration_path, :notice => I18n.t('plans.updated_plan')
    else
      flash.alert = I18n.t('plans.unable_to_update_plan')
      render :edit
    end
  end

  private
    def build_resource(*args)
      super

      if params[:user] && params[:user][:company_attributes]
        resource.company = create_company(params[:user])
      else
        resource.build_company
      end

      if params[:plan]
        resource.add_role(params[:plan])
      end

      if params[:user]
        resource[:first_name] = params[:user][:first_name]
        resource[:last_name] = params[:user][:last_name]
      end

      return resource
    end

    def create_company(params)
      company = Company.new(
        :name => params[:company_attributes][:name],
        :street_address => params[:company_attributes][:street_address],
        :postal_code => params[:company_attributes][:postal_code],
        :city => params[:company_attributes][:city],
        :country => params[:country]
      )
      company.save

      return company
    end
end
