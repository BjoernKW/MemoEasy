class ChangeDefaultReminderChoice < ActiveRecord::Migration
  def change
  	change_column :companies, :use_html_email, :boolean, :default => true
  	change_column :companies, :use_text_email, :boolean, :default => true
  	change_column :companies, :use_text_message, :boolean, :default => true
  end
end
