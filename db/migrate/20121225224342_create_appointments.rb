class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.references :company
      t.references :user
      t.text :notes

      t.timestamps
    end
    add_index :appointments, :company_id
    add_index :appointments, :user_id
  end
end
