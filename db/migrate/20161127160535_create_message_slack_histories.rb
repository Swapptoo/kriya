class CreateMessageSlackHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :message_slack_histories do |t|
      t.string :ts
      t.integer :room_id

      t.timestamps
    end
  end
end
