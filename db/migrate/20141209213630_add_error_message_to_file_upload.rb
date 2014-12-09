class AddErrorMessageToFileUpload < ActiveRecord::Migration
  def change
    add_column :file_uploads, :zencoder_error, :string
  end
end
