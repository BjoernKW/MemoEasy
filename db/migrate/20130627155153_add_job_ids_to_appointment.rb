class AddJobIdsToAppointment < ActiveRecord::Migration
  def change
  	change_table :appointments do |t|
      t.integer :reminder_email_job_id
      t.integer :text_message_job_id
    end
  end
end
