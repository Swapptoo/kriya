class AddFirstPaidAmountToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :first_paid_amount_cents, :integer, default: 0
  end
end
