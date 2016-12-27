class AddKriyaFeeToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :kriya_client_fee_cents, :integer, default: 0
    add_column :rooms, :kriya_freelancer_fee_cents, :integer, default: 0

    # Record old fee
    Room.find_each do |room|
      # Record old rule
      if room.first_paid_amount_cents > 0.0
        percentag = 30
        percentag = 20 if room.budget_cents >= 500_00

        fee = room.budget_cents.to_f * percentag / 100
        room.update_columns(kriya_client_fee_cents: fee)
      # Apply new rule
      else
        room.set_kriya_client_fee_cents
      end
    end
  end
end
