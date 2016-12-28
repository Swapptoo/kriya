class AddSourceToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :source, :integer, default: 0

    Message.with_deleted.update_all(source: 0)
  end
end
