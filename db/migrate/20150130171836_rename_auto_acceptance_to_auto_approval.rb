class RenameAutoAcceptanceToAutoApproval < ActiveRecord::Migration
  def change
    rename_column :cuts, :user_warned_of_auto_acceptance_at, :user_warned_of_auto_approval_at
  end
end
