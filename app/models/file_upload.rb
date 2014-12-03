class FileUpload < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  validates :url,  presence: true
  validates :uuid, presence: true,
                   uniqueness: true

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

  def file_name
    url.split("/").last
  end

  def determine_duration(from_job = nil)
    duration = duration_from_job(from_job)

    if duration.nil?
      return nil
    else
      duration_in_seconds = duration / 1000
      update(duration: duration_in_seconds)
      return duration_in_seconds
    end
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end

  def duration_from_job(from_job = nil)
    job = from_job || zencoder_job

    if job.nil? || job.body["job"].nil? || job.body["job"]["input_media_file"].nil?
      nil
    else
      job.body["job"]["input_media_file"]["duration_in_ms"]
    end
  end
end
