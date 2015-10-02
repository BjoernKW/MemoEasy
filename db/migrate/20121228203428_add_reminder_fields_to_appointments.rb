class AddReminderFieldsToAppointments < ActiveRecord::Migration
  def change
  	add_column :appointments, :remind_at, :datetime
  	add_column :appointments, :use_html_email, :boolean, :default => false
  	add_column :appointments, :use_text_email, :boolean, :default => false
  	add_column :appointments, :use_text_message, :boolean, :default => false
  	add_column :customers, :use_html_email, :boolean, :default => false
  	add_column :customers, :use_text_email, :boolean, :default => false
  	add_column :customers, :use_text_message, :boolean, :default => false
  	add_column :companies, :use_html_email, :boolean, :default => false
  	add_column :companies, :use_text_email, :boolean, :default => false
  	add_column :companies, :use_text_message, :boolean, :default => false
  end
end
