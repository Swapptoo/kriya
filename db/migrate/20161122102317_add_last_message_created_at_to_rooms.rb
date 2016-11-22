class AddLastMessageCreatedAtToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :last_message_created_at, :datetime

    Room.includes(:messages).find_each do |room|
      last_msg = room.messages.last || next

      room.update_column(:last_message_created_at, last_msg.created_at)
    end
  end
end
