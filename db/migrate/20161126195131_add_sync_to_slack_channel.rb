class AddSyncToSlackChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :slack_channels, :sync, :boolean, default: false
  end
end
