class ChangeStartAndEndFieldsForSlots < ActiveRecord::Migration
  def up
  	remove_column :slots, :starts_at
  	remove_column :slots, :ends_at

  	add_column :slots, :starts_at_hour, :integer
  	add_column :slots, :starts_at_minute, :integer
  	add_column :slots, :ends_at_hour, :integer
  	add_column :slots, :ends_at_minute, :integer
  end

  def down
  	add_column :slots, :starts_at, :datetime
  	add_column :slots, :ends_at, :datetime

  	remove_column :slots, :starts_at_hour
  	remove_column :slots, :starts_at_minute
  	remove_column :slots, :ends_at_hour
  	remove_column :slots, :ends_at_minute
  end
end
