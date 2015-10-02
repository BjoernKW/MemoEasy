class RenameResourceColumnInAssignments < ActiveRecord::Migration
  def change
  	rename_column :assignments, :resource_id, :staff_member_id
  end
end
