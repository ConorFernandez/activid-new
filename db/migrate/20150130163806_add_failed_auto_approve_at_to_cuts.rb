class AddFailedAutoApproveAtToCuts < ActiveRecord::Migration
  def change
    add_column :cuts, :failed_auto_approve_at, :datetime
  end
end
