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
    files = [file_uploads(:three), file_uploads(:four)]

    assert_equal 0, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_ids: files.map(&:id)

    assert_equal 2, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update removes files not included in payload" do
    project = projects(:has_files)
    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_ids: []

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
    files = project.file_uploads + [file_uploads(:three)]

    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_ids: files.map(&:id)

    assert_equal 3, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update re-uses existing while also deleting some uploads" do
    project = projects(:has_files)
    files = [file_uploads(:one), file_uploads(:three)]

    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_ids: files.map(&:id)

    assert_equal 2, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end
end
