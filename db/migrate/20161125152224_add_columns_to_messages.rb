class AddColumnsToMessages < ActiveRecord::Migration[5.0]
  def change
    change_table :messages do |t|
      t.string :slack_ts
      t.string :slack_channel
    end
  end
end
