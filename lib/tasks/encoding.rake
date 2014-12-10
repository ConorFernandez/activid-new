namespace :encoding do

  desc "Check cuts to see if they have completed encoding"
  task check_cuts: :environment do
    FileUpload.where(attachable_type: "Cut", zencoder_status: "processing").each do |upload|
      job = upload.zencoder_job

      case job.body["job"]["state"]
      when "finished"
        preview_url = job.body["job"]["output_media_files"][0]["url"]
        upload.update(zencoder_status: "finished", preview_url: preview_url)
      when "failed"
        error_message = job.body["job"]["input_media_file"]["error_message"]
        upload.update(zencoder_status: "failed", zencoder_error: error_message)
      end
    end
  end

  desc "Check user uploads to see if they have completed encoding"
  task check_user_uploads: :environment do
    FileUpload.where(attachable_type: "Project", zencoder_status: "processing").each do |upload|
      job = upload.zencoder_job
      project = upload.attachable

      case job.body["job"]["state"]
      when "finished"
        duration = job.body["job"]["input_media_file"]["duration_in_ms"] / 1000
        upload.update(zencoder_status: "finished", duration: duration)
      when "failed"
        error_message = job.body["job"]["input_media_file"]["error_message"]
        upload.update(zencoder_status: "failed", zencoder_error: error_message)
      end
    end
  end
end