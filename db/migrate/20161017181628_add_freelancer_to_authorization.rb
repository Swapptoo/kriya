class AddFreelancerToAuthorization < ActiveRecord::Migration[5.0]
  def change
    add_reference :authorizations, :freelancer, foreign_key: true
  end
end
