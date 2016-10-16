class CreateFreelancerSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :freelancer_skills do |t|
      t.integer :freelancer_id
      t.integer :skill_id
    end
    add_index :freelancer_skills, [:freelancer_id, :skill_id], :unique => true
  end
end