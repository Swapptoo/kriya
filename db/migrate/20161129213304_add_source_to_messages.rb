class AddSourceToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :source, :integer, default: 0

    Message.update_all(source: 0)
  end
end
