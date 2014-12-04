class CreateCuts < ActiveRecord::Migration
  def change
    create_table :cuts do |t|
      t.integer :project_id, :uploader_id
      t.timestamps
    end
  end
end
