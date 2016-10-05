class CreateUserSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :user_skills do |t|
      t.integer :user_id
      t.integer :skill_id
    end
    add_index :user_skills, [:user_id, :skill_id], :unique => true
  end
end
