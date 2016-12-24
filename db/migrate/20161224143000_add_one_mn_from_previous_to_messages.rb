class AddOneMnFromPreviousToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :one_mn_from_previous, :boolean, default: false

    Message.includes(:user).find_each do |new_msg|
      message = new_msg.previous_message
      new_msg.update_columns(one_mn_from_previous: true) if !message.nil? && message.user == new_msg.user && new_msg.seconds_from_message(message) <= 60
    end
  end
end
