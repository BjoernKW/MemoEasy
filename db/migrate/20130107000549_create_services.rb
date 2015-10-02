class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.integer :duration
      t.references :appointment

      t.timestamps
    end
    change_table :appointments do |t|
      t.references :service
    end
    add_index :appointments, :service_id
  end
end
