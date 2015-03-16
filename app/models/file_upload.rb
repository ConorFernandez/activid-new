class FileUpload < ActiveRecord::Base
  FORMATS = {
    video: %w(mov mp4 mpg flv wmv 3gp asf rm swf avi),
    image: %w(tif tiff gif jpeg jpg jif jfif jp2 jpx j2c png pdf psd),
    music: %w(mp3 aac ogg wma wav mp4 flac)
  }
  belongs_to :attachable, polymorphic: true

  before_validation :generate_uuid, on: :create,
                                    if: Proc.new { |p| p.uuid.blank? }

  validates :url,  presence: true,
                   if: Proc.new { |p| p.source_url.blank? }
  validates :source_url, presence: true,
                         if: Proc.new { |p| p.url.blank? }
  validates :uuid, presence: true,
                   uniqueness: true

# Kinds of URL on this object:
# - url / intially meaning a file which came in via direct upload. zencoder wants this prepended with s3://my-path
# - target_url / a local value, not in schema 
# - source_url / meaning a file via a dropbox url. zencoder wants this prepended with http://my-path plus some metadata about access control

  def to_param
    uuid
  end

  def create_s3_url!
   
    if self.url == nil
      @target_url = "http://#{ENV["S3_BUCKET"]}.s3.amazonaws.com/uploads/#{SecureRandom.uuid}/#{file_name}"
      update(url: @target_url)
      puts "FILE UPLOAD: Dropbox upload. File_upload url updated to " + self.url
    else
      puts "FILE UPLOAD: Direct upload. File_upload url already exists"
      p self.url
    end 
  end  

  def queue_zencoder_job(attachable_type)
    job =
      case attachable_type
      when "project"
        if source_url == nil

          puts "FILE UPLOAD: queue_zencoder_job sent a direct upload file to Zencoder: " + url  
          Zencoder::Job.create({
            input: "s3:" + url,
            outputs: {
              type: "transfer-only"
            }
          })

        else
          puts "FILE UPLOAD: queue_zencoder_job sent a dropbox upload to Zencoder: " + url  
          Zencoder::Job.create({
            input: source_url,
            outputs: {
              type: "transfer-only",
              url: url,
              access_control: [{
                permission: ["READ_ACP", "READ"],
                grantee: "http://acs.amazonaws.com/groups/global/AllUsers"
              }]
            }
          })
        end
      when "cut"
        Zencoder::Job.create({
          input: "s3:#{url}",
          output: {
            width: 480,
            url: "http://#{ENV["S3_BUCKET"]}.s3.amazonaws.com/previews/#{SecureRandom.uuid}.#{extension}",
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
        puts "FILE UPLOAD: ----- ERROR: queue_zencoder_job couldn't find a file_upload URL for cut -----"
      end

    puts "FILE UPLOAD: Inspecting zencoder job"
    p job
    update(zencoder_job_id: job.body["id"], zencoder_status: "processing") if job
  end

  def zencoder_job
    zencoder_job_id ? Zencoder::Job.details(zencoder_job_id) : nil
  end

  def file_name
    (url || source_url || "").split("/").last.split(/\?(?!\.)/).first
  end

  def extension
    # p "FILE UPLOAD: extension runs: " + file_name.split(".").last.downcase + " from " + file_name
    file_name.split(".").last.downcase
  end

  def file_type
    if FORMATS[:video].include?(extension)
      :video
    elsif FORMATS[:music].include?(extension)
      :music
    elsif FORMATS[:image].include?(extension)
      :image
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

  def image?
    file_type == :image
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
    puts "FILE UPLOAD: UUID generated: " + self.uuid
  end
end
