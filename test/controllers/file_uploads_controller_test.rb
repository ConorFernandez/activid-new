require "test_helper"

class FileUploadsControllerTest < ActionController::TestCase
  test "users can delete files that belong to their own projects" do
    project = projects(:has_files)
    upload = project.file_uploads.first
    sign_in project.user

    delete :destroy, id: upload

    assert_equal nil, FileUpload.find_by_id(upload.id)
  end

  test "anonymous users can delete files that belong to ownerless projects" do
    project = projects(:has_files_no_owner)
    upload = project.file_uploads.first

    delete :destroy, id: upload

    assert_equal nil, FileUpload.find_by_id(upload.id)
  end

  test "users cannot delete files that belong to another user's project" do
    project = projects(:has_files)
    upload = project.file_uploads.first
    sign_in users(:wilson)

    delete :destroy, id: upload

    assert_not_equal nil, FileUpload.find_by_id(upload.id)
  end

  test "if a project_uuid is present, attach the upload to the project immediately" do
    project = projects(:has_files)
    sign_in project.user
    url = "http://mysweetvideo.com/cinemagic.mp4"

    post :create, file_upload: {url: url}, project_uuid: project.uuid

    assert project.reload.file_uploads.map(&:url).include?(url)
  end

  test "user can post a file with just a source_url" do
    project = projects(:has_files)
    sign_in project.user
    source_url = "http://dl.dropboxusercontent.com/cinemagic.mp4"

    post :create, file_upload: {source_url: source_url}, project_uuid: project.uuid

    assert project.reload.file_uploads.map(&:source_url).include?(source_url)
  end

  test "converts dropbox source URL to actual URL where file is" do
    project = projects(:has_files)
    sign_in project.user
    source_url = "http://www.dropbox.com/cinemagic.mp4"

    post :create, file_upload: {source_url: source_url}, project_uuid: project.uuid

    assert_equal "http://dl.dropboxusercontent.com/cinemagic.mp4", project.reload.file_uploads.last.source_url
  end
end
