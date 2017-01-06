class ChangeDefaultValueForStatusInFreelancers < ActiveRecord::Migration[5.0]
  def change
    change_column_default :freelancers, :status, 'pause'
  end
end
