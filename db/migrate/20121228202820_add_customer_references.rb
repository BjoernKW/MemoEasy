class AddCustomerReferences < ActiveRecord::Migration
  def change
  	change_table :appointments do |t|
      t.references :customer
    end
    add_index :appointments, :customer_id
  end
end
