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

  def queue_zencoder_job(attachable_type)
    job =
      case attachable_type
      when "project"
        Zencoder::Job.create({
          input: "s3:#{url}",
          outputs: {
            type: "transfer-only"
          }
        })
      when "cut"
        Zencoder::Job.create({
          input: "s3:#{url}",
          output: {
            width: 480,
            watermarks: {
              url: "http://activid-stagingg.s3.amazonaws.com/watermark.png",
              height: "50%",
              x: "centered",
              y: "centered"
            }
          }
        })
      else
        nil
      end

    update(zencoder_job_id: job.body["id"], zencoder_status: "processing") if job
  end

  def zencoder_job
    zencoder_job_id ? Zencoder::Job.details(zencoder_job_id) : nil
  end

  def file_name
    (url || "").split("/").last
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

  def file_type
    match = file_name.match(/\.(.+)$/)
    extension = (match && match[1]) ? match[1].downcase : nil

    case extension
    when /mov|mp4|mpg|flv|wmv|3gp|asf|rm|swf|avi/
      :video
    else
      nil
    end
  end

  def video?
    file_type == :video
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
