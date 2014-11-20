class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.string :url, :attachable_type
      t.integer :attachable_id

      t.timestamps
    end

    add_index :file_uploads, [:attachable_id, :attachable_type]
  end
end
