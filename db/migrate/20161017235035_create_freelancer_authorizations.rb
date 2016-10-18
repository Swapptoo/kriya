class CreateFreelancerAuthorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :freelancer_authorizations do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :refresh_token
      t.datetime :expires_at
      t.belongs_to :freelancer, foreign_key: true

      t.timestamps
    end
    add_index :freelancer_authorizations, :provider
    add_index :freelancer_authorizations, :uid
  end
end