class FileUploadsController < ApplicationController
  layout false

  def create
    @file_upload = FileUpload.new(file_upload_params)

    if @file_upload.save
      @file_upload.queue_zencoder_job # todo: move this to a background worker

      render json: @file_upload
    else
      render json: @file_upload.errors, status: :unprocessable_entity
    end
  end

  private

  def file_upload_params
    params.require(:file_upload).permit(:url)
  end
end
