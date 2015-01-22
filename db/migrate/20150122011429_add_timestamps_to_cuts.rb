class AddTimestampsToCuts < ActiveRecord::Migration
  def change
    add_column :cuts, :processed_at, :datetime
    add_column :cuts, :user_warned_of_auto_acceptance_at, :datetime
  end
end
