class FileUpload < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  validates :url, uniqueness: true
  validates :uuid, :presence => true,
                   :uniqueness => true

  def to_param
    uuid
  end

  def queue_zencoder_job
    job = Zencoder::Job.create({
      input: "s3:#{url}",
      outputs: {
        type: "transfer-only"
      }
    })

    update(zencoder_job_id: job.body["id"])
  end

  def zencoder_job
    zencoder_job_id ? Zencoder::Job.details(zencoder_job_id) : nil
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
