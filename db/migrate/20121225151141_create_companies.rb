class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :company_register_id
      t.string :bank_account_number
      t.string :bank_id
      t.string :bank_name

      t.timestamps
    end
  end
end
