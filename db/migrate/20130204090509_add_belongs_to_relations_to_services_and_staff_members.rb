class AddBelongsToRelationsToServicesAndStaffMembers < ActiveRecord::Migration
  def change
  	change_table :services do |t|
      t.references :company
    end
    change_table :staff_members do |t|
      t.references :company
    end
    add_index :services, :company_id
    add_index :staff_members, :company_id
  end
end
