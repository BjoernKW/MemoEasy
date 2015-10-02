class AddOptInAttributes < ActiveRecord::Migration
  def change
  	add_column :customers, :email_confirmed_at, :string
  	add_column :customers, :mobile_phone_confirmed_at, :string
  	add_column :customers, :email_confirmation_token, :string
  	add_column :customers, :mobile_confirmation_token, :string
  end
end
