require 'test_helper'

class FileUploadTest < ActiveSupport::TestCase
  test "identifies the correct extensions as video files" do
    urls = [
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.mp4",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.MP4",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.mov",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.mpg",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.flv",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.wmv",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.3gp",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.asf",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.rm",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.swf",
      "//activid-dev.s3.amazonaws.com/uploads/uuid/wrecking_ball.avi"
    ]

    urls.each do |url|
      file_upload = FileUpload.new(url: url)
      assert_equal :video, file_upload.file_type, url
    end
  end

  test "identifies videos with a source_url but no url as having the correct type" do
    url = "https://www.dropbox.com/s/whjiecwxtlk2lkn/wrecking_ball.mp4?dl=0"
    file_upload = FileUpload.new(source_url: url)
    assert_equal :video, file_upload.file_type
  end

  test "queue_zencoder_job queues the correct job for direct s3 user uploads" do
    url = "//activid.s3.amazonaws.com/movie.mp4"
    upload = FileUpload.new(url: url)

    Zencoder::Job.expects(:create).with({
      input: "s3:#{url}",
      outputs: {
        type: "transfer-only"
      }
    })

    upload.queue_zencoder_job("project")
  end

  test "queue_zencoder_job queues the correct job for user uploads from dropbox and updates the url on the record" do
    source_url = "https://dl.dropboxusercontent.com/movie.mp4"
    target_url = "http://#{ENV["S3_BUCKET"]}.s3.amazonaws.com/uploads/cool-uuid/movie.mp4"

    upload = FileUpload.new(source_url: source_url)
    SecureRandom.expects(:uuid).returns("cool-uuid")
    upload.expects(:update).with(url: target_url)

    Zencoder::Job.expects(:create).with({
      input: source_url,
      outputs: {
        type: "transfer-only",
        url: target_url,
        access_control: [{
          permission: ["READ_ACP", "READ"],
          grantee: "http://acs.amazonaws.com/groups/global/AllUsers"
        }]
      }
    })

    upload.queue_zencoder_job("project")
  end
end
