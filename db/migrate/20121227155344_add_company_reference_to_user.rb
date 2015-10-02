class AddCompanyReferenceToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :company
    end
    add_index :users, :company_id
  end
end
