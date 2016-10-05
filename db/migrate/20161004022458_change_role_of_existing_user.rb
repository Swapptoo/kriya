class ChangeRoleOfExistingUser < ActiveRecord::Migration[5.0]
  class User < ActiveRecord::Base
  end

  def up
    User.find_each do |user|
      if user.email == 'manager@goomp.co'
        user.role = 2
      elsif !user.role.present?
        user.role = 0
      end
      user.save!
    end
  end
end
