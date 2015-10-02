class AddCompanyInformation < ActiveRecord::Migration
  def change
  	change_table :companies do |t|
      t.string :street_address
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :phone_number
      t.string :vat_id
    end
  end
end
