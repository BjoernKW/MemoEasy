class AddRecurringAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :repeat_in_days, :integer, :default => 0
  end
end
