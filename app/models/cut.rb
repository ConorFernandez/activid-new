class Cut < ActiveRecord::Base
  belongs_to :project
  belongs_to :uploader, class_name: "User"

  has_one :file_upload, as: :attachable

  def processed?
    file_upload.zencoder_finished? && file_upload.preview_url.present?
  end

  def failed?
    file_upload.zencoder_failed?
  end

  def preview_url
    file_upload.try(:preview_url)
  end

  def zencoder_error
    file_upload.try(:zencoder_error)
  end
end
