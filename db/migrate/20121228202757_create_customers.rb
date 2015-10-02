class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :mobile_phone
      t.references :company

      t.timestamps
    end
    add_index :customers, :company_id
  end
end
