class FileUpload < ActiveRecord::Base
  FORMATS = {
    video: %w(mov mp4 mpg flv wmv 3gp asf rm swf avi),
    music: %w(mp3)
  }
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
            url: "http://#{ENV["S3_BUCKET"]}.s3.amazonaws.com/previews/#{UUID.new.generate}.#{url.split(".").last}",
            public: true,
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
    extension = file_name.split(".").last.downcase

    if FORMATS[:video].include?(extension)
      :video
    elsif FORMATS[:music].include?(extension)
      :music
    else
      nil
    end
  end

  def video?
    file_type == :video
  end

  def music?
    file_type == :music
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
