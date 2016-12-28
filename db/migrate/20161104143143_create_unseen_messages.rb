class CreateUnseenMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :unseen_messages do |t|
      t.references :user
      t.references :freelancer
      t.references :message
      t.references :room

      t.timestamps
    end

    Message.with_deleted.un_seen.includes(:room, :user, :freelancer).find_each do |message|
      room = message.room
      users = []

      users << room.user
      users << room.manager
      users += room.accepted_freelancers.to_a
      users -= [message.user, message.freelancer]

      users.each do |user|
        user.unseen_messages.create(message: message, room: message.room)
      end
    end
  end
end
