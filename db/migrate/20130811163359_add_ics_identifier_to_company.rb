class AddIcsIdentifierToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :ics_identifier, :string

    # add identifier to existing companies
    Company.reset_column_information
    Company.find_each do |company|
      company.save
    end
  end
end
