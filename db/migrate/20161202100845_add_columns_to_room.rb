class AddColumnsToRoom < ActiveRecord::Migration[5.0]
  def change
    change_table :rooms do |t|
      t.string :website
      t.integer :total_employee
    end
  end
end
