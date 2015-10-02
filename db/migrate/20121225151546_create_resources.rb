class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.references :company

      t.timestamps
    end
    add_index :resources, :company_id
  end
end
