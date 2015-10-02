class AddColourToStaffMember < ActiveRecord::Migration
  def change
  	change_table :staff_members do |t|
      t.string :colour, :null => false, :default => '#3a87ad'

      # add colour to existing companies
    	StaffMember.reset_column_information
    	StaffMember.find_each do |staff_member|
  	  	staff_member.colour = MemoEasy::Application.config.default_colours[staff_member.id % MemoEasy::Application.config.default_colours.length]
  	  	staff_member.save
  		end
    end
  end
end
