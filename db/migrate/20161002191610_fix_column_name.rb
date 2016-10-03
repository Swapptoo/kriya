class FixColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :type, :category
  end
end
