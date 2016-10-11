class CreateJoinTableUserRoom < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms_users do |t|
      t.integer :room_id
      t.integer :user_id
      t.string :status, default: 'pending'
    end
    add_index :rooms_users, [:room_id, :user_id], :unique => true
  end
end
