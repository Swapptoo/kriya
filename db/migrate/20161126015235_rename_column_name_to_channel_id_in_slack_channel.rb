class RenameColumnNameToChannelIdInSlackChannel < ActiveRecord::Migration[5.0]
  def change
    rename_column :slack_channels, :name, :channel_id
  end
end
