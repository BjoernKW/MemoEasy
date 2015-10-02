desc "Heroku Scheduler"

task :create_next_appointments => :environment do
	appointments = Appointment.where(
      "DATE(starts_at) = ? AND repeat_in_days > 0", Date.today
    )

    appointments.each do |appointment|
	    appointment.create_next_appointment
	end
end
