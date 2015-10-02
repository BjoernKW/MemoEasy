class CreateStaffMembers < ActiveRecord::Migration
  def change
    create_table :staff_members do |t|

      t.timestamps
    end
  end
end
