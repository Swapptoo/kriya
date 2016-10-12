class AddAuthenticationTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :authentication_token, :string, limit: 30
    add_index :users, :authentication_token, unique: true
    User.find_each { |u| u.update_attributes(updated_at: Time.now) }
  end
end
