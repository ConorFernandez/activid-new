class FileUploadsController < ApplicationController
  layout false

  def create
    @file_upload = FileUpload.new(file_upload_params)

    unless @file_upload.save
      render status: 400
    end
  end

  private

  def file_upload_params
    params.require(:file_upload).permit(:url)
  end
end
