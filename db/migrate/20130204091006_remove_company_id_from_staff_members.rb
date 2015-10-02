class RemoveCompanyIdFromStaffMembers < ActiveRecord::Migration
  def up
  	remove_column :staff_members, :company_id
  end

  def down
  	add_column :staff_members, :company_id, :references
  	add_index :staff_members, :company_id
  end
end
