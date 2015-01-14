class AddRejectReasonToCut < ActiveRecord::Migration
  def change
    add_column :cuts, :reject_reason, :text
  end
end
