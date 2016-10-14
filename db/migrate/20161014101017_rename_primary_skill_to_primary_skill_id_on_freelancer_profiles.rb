class RenamePrimarySkillToPrimarySkillIdOnFreelancerProfiles < ActiveRecord::Migration[5.0]
  def change
    rename_column :freelancer_profiles, :primary_skill, :primary_skill_id
  end
end
