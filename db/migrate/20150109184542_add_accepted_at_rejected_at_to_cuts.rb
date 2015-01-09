class AddAcceptedAtRejectedAtToCuts < ActiveRecord::Migration
  def change
    add_column :cuts, :accepted_at, :datetime
    add_column :cuts, :rejected_at, :datetime
  end
end
