class AddStatusToSlackChannels < ActiveRecord::Migration[5.0]
  def change
    add_column :slack_channels, :status, :integer, default: 0
  end
end
