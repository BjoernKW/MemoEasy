class RemoveResourceTable < ActiveRecord::Migration
  def up
    drop_table :resources

    change_table :staff_members do |t|
      t.string :name
      t.references :company
    end
    add_index :staff_members, :company_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
