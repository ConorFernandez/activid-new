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

  def presigned_post
    presigned_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :public_read)

    render json: {
      post_url: presigned_post.url.to_s,
      form_data: presigned_post.fields,
      remote_host: presigned_post.url.host
    }
  end

  private

  def file_upload_params
    params.require(:file_upload).permit(:url)
  end
end
