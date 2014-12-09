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
end
