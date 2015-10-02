class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.references :company

      t.timestamps
    end
    add_index :slots, :company_id
  end
end
