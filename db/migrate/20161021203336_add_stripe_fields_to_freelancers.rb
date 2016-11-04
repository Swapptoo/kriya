class AddStripeFieldsToFreelancers < ActiveRecord::Migration[5.0]
  def change
    add_column :freelancers, :stripe_publishable_key, :string
    add_column :freelancers, :stripe_token, :string
    add_column :freelancers, :stripe_client_id, :string
  end
end
