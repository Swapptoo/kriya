class CreateJoinTableRoomsFreelancers < ActiveRecord::Migration[5.0]
  def change
    create_table :freelancers_rooms do |t|
      t.integer :freelancer_id
      t.integer :room_id
      t.string :status, default: 'pending'
    end
    add_index :freelancers_rooms, [:freelancer_id, :room_id], :unique => true
  end
end