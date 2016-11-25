class AddAcceptKriyaPolicyToTreelancers < ActiveRecord::Migration[5.0]
  def change
    add_column :freelancers, :accepted_kriya_policy, :boolean, default: false
  end
end
