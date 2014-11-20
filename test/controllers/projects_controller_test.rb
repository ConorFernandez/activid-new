require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  test "POST create redirects to step 2" do
    data = {
      name: "My Project",
      category: Project::CATEGORIES.keys.first,
      desired_length: Project::LENGTHS.keys.first,
      instructions: "None"
    }

    post :create, step: 1, project: data

    project = Project.last

    assert_redirected_to project_step2_path(project)
  end

  test "PUT update attaches file upload objects" do
    project = projects(:no_files)
    assert_equal 0, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_urls: ["one", "two"]

    assert_equal 2, project.file_uploads.count
    assert_equal ["one", "two"].sort, project.file_uploads.map(&:url).sort
  end

  test "PUT update removes files not included in payload" do
    project = projects(:has_files)
    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_urls: []

    assert_equal 0, project.file_uploads.count
  end

  test "PUT update removes all files if param is missing" do
    project = projects(:has_files)
    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2

    assert_equal 0, project.file_uploads.count
  end

  test "PUT update re-uses existing files" do
    project = projects(:has_files)
    assert_equal 2, project.file_uploads.count
    file_upload_count = FileUpload.count

    put :update, id: project.uuid, step: 2, file_upload_urls: project.file_uploads.map(&:url) + ["new_file_url"]

    assert_equal 3, project.file_uploads.count
    assert_equal file_upload_count + 1, FileUpload.count
  end

  test "PUT update re-uses existing while also deleting some uploads" do
    project = projects(:has_files)
    assert_equal 2, project.file_uploads.count
    file_upload_count = FileUpload.count
    urls = [project.file_uploads.first.url, "new_file_url"]

    put :update, id: project.uuid, step: 2, file_upload_urls: urls

    assert_equal 2, project.file_uploads.count
    assert_equal urls.sort, project.file_uploads.map(&:url).sort
    assert_equal file_upload_count + 1, FileUpload.count
  end
end
