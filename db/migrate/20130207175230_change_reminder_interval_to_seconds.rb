class ChangeReminderIntervalToSeconds < ActiveRecord::Migration
  def up
  	change_column :companies, :reminder_interval, :integer, :default => 1800
  end

  def down
  	change_column :companies, :reminder_interval, :integer, :default => 30
  end
end
