class CreateCustomerSets < ActiveRecord::Migration
  def change
    create_table :customer_sets do |t|

      t.timestamps
    end
  end
end
