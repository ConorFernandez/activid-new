class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :project_id, :poster_id
      t.text :body

      t.timestamps
    end
  end
end
