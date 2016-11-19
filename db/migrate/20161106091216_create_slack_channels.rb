class CreateSlackChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :slack_channels do |t|
      t.string :name
      t.string :uid
      t.string :token
      t.string :web_hook_url
      t.string :scope
      t.string :team_name
      t.string :team_id
      t.references :room
      t.references :user
      t.references :freelancer

      t.timestamps
    end
  end
end
