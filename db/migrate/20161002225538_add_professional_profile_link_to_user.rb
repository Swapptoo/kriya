class AddProfessionalProfileLinkToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :professional_profile_link1, :string
    add_column :users, :professional_profile_link2, :string
  end
end
