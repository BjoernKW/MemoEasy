class ChangeConfirmationAtFieldsToDateTime < ActiveRecord::Migration
  def up
  	remove_column :customers, :email_confirmed_at
  	remove_column :customers, :mobile_phone_confirmed_at
  	add_column :customers, :email_confirmed_at, :datetime
  	add_column :customers, :mobile_phone_confirmed_at, :datetime
  end

  def down
  	remove_column :customers, :email_confirmed_at
  	remove_column :customers, :mobile_phone_confirmed_at
  	add_column :customers, :email_confirmed_at, :string
  	add_column :customers, :mobile_phone_confirmed_at, :string
  end
end
