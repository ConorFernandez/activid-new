class Cut < ActiveRecord::Base
  include Cut::Status

  belongs_to :project
  belongs_to :uploader, class_name: "User"

  has_one :file_upload, as: :attachable

  validate :has_upload

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

  def approve!
    project.charge! && update(approved_at: Time.now)
  end

  def reject!(reason)
    if reason.present?
      update(rejected_at: Time.now, reject_reason: reason)
    else
      false
    end
  end

  private

  def has_upload
    errors.add(:base, "Must have an attached file") unless file_upload.present?
  end
end
