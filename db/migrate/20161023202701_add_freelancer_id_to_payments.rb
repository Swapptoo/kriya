class AddFreelancerIdToPayments < ActiveRecord::Migration[5.0]
  def change
    add_reference :payments, :freelancer, foreign_key: true
  end
end
