class DeviseCreateFreelancers < ActiveRecord::Migration[5.0]
  def change
    create_table :freelancers do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false

      t.string :username
      t.string :bio
      t.string :first_name
      t.string :last_name
      t.string :picture
      t.string :headline
      t.string :work_experience
      t.string :gender
      t.string :avatar

      t.string :category
      t.datetime :availability
      t.integer :primary_skill, foreign_key: {to_table: :skills}
      t.string :years_of_experiences
      t.string :project_description
      t.string :project_url
      t.string :professional_profile_link1
      t.string :professional_profile_link2
      t.string :status, default: 'pause'

      t.string :authentication_token, limit: 30
    end

    add_index :freelancers, :email,                unique: true
    add_index :freelancers, :reset_password_token, unique: true
    
    add_index :freelancers, :authentication_token, unique: true
    # add_index :freelancers, :confirmation_token,   unique: true
    # add_index :freelancers, :unlock_token,         unique: true
  end
end
