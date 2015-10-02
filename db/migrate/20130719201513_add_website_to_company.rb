class AddWebsiteToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :website_url, :string
  	add_column :companies, :logo_url, :string
  end
end
