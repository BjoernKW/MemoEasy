class AddPublicIdentifierToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :public_identifier, :string

    # add public identifier to existing companies
    Company.reset_column_information
    Company.find_each do |company|
  	  company.save
  	end
  end
end
