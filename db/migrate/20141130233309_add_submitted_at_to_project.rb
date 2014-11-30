class AddSubmittedAtToProject < ActiveRecord::Migration
  def change
    add_column :projects, :submitted_at, :datetime
  end
end
