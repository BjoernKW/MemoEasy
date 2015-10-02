class RenameMobileConfirmationToken < ActiveRecord::Migration
  def change
  	rename_column :customers, :mobile_confirmation_token, :mobile_phone_confirmation_token
  end
end
