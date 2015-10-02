class AddBlockers < ActiveRecord::Migration
  def change
  	add_column :slots, :blocker, :boolean, :default => false
  end
end
