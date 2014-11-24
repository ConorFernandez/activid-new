class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.string :url, :attachable_type, :uuid, :thumbnail_url
      t.integer :attachable_id, :zencoder_job_id, :duration

      t.timestamps
    end

    add_index :file_uploads, [:attachable_id, :attachable_type]
    add_index :file_uploads, :uuid
  end
end
