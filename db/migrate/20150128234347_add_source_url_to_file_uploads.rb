class AddSourceUrlToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :source_url, :string
  end
end
