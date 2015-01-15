class AddAttemptedToPayEditorAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :attempted_to_pay_editor_at, :datetime
  end
end
