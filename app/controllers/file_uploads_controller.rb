class FileUploadsController < ApplicationController
  layout false
  before_filter :load_file_upload, only: :destroy

  def create
    @file_upload = FileUpload.new(file_upload_params)

    if @file_upload.save
      @file_upload.queue_zencoder_job(params[:attachable_type]) if @file_upload.video?
      attach_file_upload(@file_upload) if params[:project_uuid].present?

      render json: @file_upload
    else
      render json: @file_upload.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @file_upload.destroy if can_destroy?(@file_upload)
    render json: {}
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
    if params[:file_upload][:source_url].present?
      params[:file_upload][:source_url] = params[:file_upload][:source_url].gsub("www.dropbox.com", "dl.dropboxusercontent.com")
    end

    params.require(:file_upload).permit(:url, :source_url)
  end

  def load_file_upload
    @file_upload = FileUpload.where(uuid: params[:id]).first
  end

  def can_destroy?(file_upload)
    file_upload.attachable.is_a?(Project) &&
      (file_upload.attachable.user.nil? || file_upload.attachable.user == current_user)
  end

  def attach_file_upload(file_upload)
    project = Project.where(uuid: params[:project_uuid]).first

    if project && (project.user == current_user || project.user.nil?)
      file_upload.update(attachable: project)
    end
  end
end
