class ChangeSlotTimestamps < ActiveRecord::Migration
  def up
  	change_column :slots, :starts_at, :time
  	change_column :slots, :ends_at, :time
  end

  def down
  	change_column :slots, :starts_at, :datetime
  	change_column :slots, :ends_at, :datetime
  end
end
