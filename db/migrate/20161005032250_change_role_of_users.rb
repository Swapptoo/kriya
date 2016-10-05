class ChangeRoleOfUsers < ActiveRecord::Migration[5.0]
  class User < ActiveRecord::Base
  end

  def up
    User.find_each do |user|
      if user.role == '2'
        user.role = 'manager'
      elsif user.role == '1'
        user.role = 'freelancer'
      elsif user.role == '0'
        user.role = 'client'
      end
      user.save!
    end
  end
end
