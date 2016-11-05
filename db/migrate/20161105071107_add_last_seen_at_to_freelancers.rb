class AddLastSeenAtToFreelancers < ActiveRecord::Migration[5.0]
  def change
    add_column :freelancers, :last_seen_at, :datetime
  end
end
