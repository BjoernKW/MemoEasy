class ChangeDefaultReminderInterval < ActiveRecord::Migration
	def up
		change_column :companies, :reminder_interval, :integer, :default => 86400
	end
end
