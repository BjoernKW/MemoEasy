class AddReminderIntervalToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :reminder_interval, :integer, :default => 30
  end
end
