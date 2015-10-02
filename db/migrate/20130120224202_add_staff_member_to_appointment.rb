class AddStaffMemberToAppointment < ActiveRecord::Migration
  def change
  	change_table :appointments do |t|
      t.references :staff_member
    end
    add_index :appointments, :staff_member_id
  end
end
