class AddEditorIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :editor_id, :integer
    add_index :projects, :editor_id
  end
end
