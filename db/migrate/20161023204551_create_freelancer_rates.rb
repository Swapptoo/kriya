class CreateFreelancerRates < ActiveRecord::Migration[5.0]
  def change
    create_table :freelancer_rates do |t|
      t.timestamps
      t.integer :rate
      t.belongs_to :freelancer, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.belongs_to :room, foreign_key: true
      t.belongs_to :freelancers_room, foreign_key: true
    end
  end
end
