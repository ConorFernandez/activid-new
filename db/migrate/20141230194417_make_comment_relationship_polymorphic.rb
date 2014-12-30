class MakeCommentRelationshipPolymorphic < ActiveRecord::Migration
  def change
    remove_column :comments, :project_id
    add_column :comments, :commentable_id, :integer
    add_column :comments, :commentable_type, :string

    add_index :comments, [:commentable_id, :commentable_type]
  end
end
