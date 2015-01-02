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
              width: 100,
              x: 10,
              y: "-10",
              opacity: 0.75
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

  def zencoder_finished?
    zencoder_status == "finished"
  end

  def zencoder_failed?
    zencoder_status == "failed"
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
