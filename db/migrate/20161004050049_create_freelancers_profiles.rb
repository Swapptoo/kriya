class CreateFreelancersProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :freelancer_profiles do |t|
      t.integer :user_id
      t.string :category
      t.datetime :availability
      t.integer :primary_skill, foreign_key: {to_table: :skills}
      t.string :years_of_experiences
      t.string :project_description
      t.string :project_url
      t.string :professional_profile_link1
      t.string :professional_profile_link2
      t.string :status, default: 'pause'
    end

    add_index "freelancer_profiles", ["user_id"], name: "index_freelancer_profiles_on_user_id", using: :btree
  end
end