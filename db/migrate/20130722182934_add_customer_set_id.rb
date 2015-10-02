class AddCustomerSetId < ActiveRecord::Migration
  def change
    change_table :customers do |t|
      t.references :customer_set
    end
    add_index :customers, :customer_set_id
  end
end
