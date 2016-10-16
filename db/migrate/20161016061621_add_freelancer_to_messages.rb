class AddFreelancerToMessages < ActiveRecord::Migration[5.0]
  def change
    add_reference :messages, :freelancer, foreign_key: true
  end
end
