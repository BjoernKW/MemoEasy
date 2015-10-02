class AddCountryToUsers < ActiveRecord::Migration
  def change
	change_table :users do |t|
      t.string :country
    end
  end
end
