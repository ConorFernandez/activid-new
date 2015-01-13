class RenameAcceptedAtToApprovedAt < ActiveRecord::Migration
  def change
    rename_column :cuts, :accepted_at, :approved_at
  end
end
