class AddAppointmentConfirmation < ActiveRecord::Migration
  def change
    add_column :companies, :send_appointment_confirmation, :boolean, :default => false
  end
end
