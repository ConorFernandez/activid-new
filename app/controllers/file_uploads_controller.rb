class FileUploadsController < ApplicationController
  layout false

  def create
    @file_upload = FileUpload.new(file_upload_params)

    if @file_upload.save
      # todo: move this to a background worker
      @file_upload.queue_zencoder_job
    else
      render status: 400
    end
  end

  private

  def file_upload_params
    params.require(:file_upload).permit(:url)
  end
end
