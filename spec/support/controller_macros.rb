module ControllerMacros
  def login_admin
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      @company = FactoryGirl.create(:company)
      @admin = FactoryGirl.create(:admin, :company => @company)
      sign_in @admin
    end
  end

  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @company = FactoryGirl.create(:company)
      @user = FactoryGirl.create(:user, :company => @company)
      sign_in @user
    end
  end
end
