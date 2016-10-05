class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :type, :string
    add_column :users, :availability, :datetime
    add_column :users, :skills, :string, array: true, default: []
    add_column :users, :primary_skill, :string
    add_column :users, :years_of_experiences, :integer
    add_column :users, :project_description, :string
    add_column :users, :project_url, :string
  end
end
