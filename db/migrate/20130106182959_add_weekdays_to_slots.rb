class AddWeekdaysToSlots < ActiveRecord::Migration
  def change
  	add_column :slots, :weekday, :integer
  end
end
