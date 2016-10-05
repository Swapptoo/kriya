class RemoveColumnsFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :category
    remove_column :users, :availability
    remove_column :users, :skills
    remove_column :users, :primary_skill
    remove_column :users, :years_of_experiences
    remove_column :users, :project_description
    remove_column :users, :project_url
    remove_column :users, :professional_profile_link1
    remove_column :users, :professional_profile_link2
  end
end
