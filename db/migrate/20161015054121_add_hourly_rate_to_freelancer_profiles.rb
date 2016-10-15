class AddHourlyRateToFreelancerProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :freelancer_profiles, :hourly_rate, :integer, null: false, default: 0
  end
end
