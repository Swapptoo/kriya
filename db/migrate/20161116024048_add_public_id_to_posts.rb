class AddPublicIdToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :token, :string, index: true
    Post.find_each { |p| p.update(updated_at: Time.now) }
  end
end
