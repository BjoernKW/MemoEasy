class AddConfirmableToCustomers < ActiveRecord::Migration
  def up
    add_column :customers, :confirmation_token, :string
    add_column :customers, :confirmed_at, :datetime
    add_column :customers, :confirmation_sent_at, :datetime
    add_index :customers, :confirmation_token, :unique => true

    Customer.update_all(:confirmed_at => Time.now)
  end

  def down
    remove_column :customers, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
