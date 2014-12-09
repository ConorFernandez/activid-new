class AddZencoderStatusAndPreviewUrlToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :zencoder_status, :string
    add_column :file_uploads, :preview_url, :string
  end
end
