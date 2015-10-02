class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :slot
      t.references :resource

      t.timestamps
    end
    add_index :assignments, :slot_id
    add_index :assignments, :resource_id
  end
end
