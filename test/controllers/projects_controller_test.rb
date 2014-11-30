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

  test "POST create assigns project to current_user" do
    user = users(:joey)
    sign_in user

    data = {
      name: "My Project",
      category: Project::CATEGORIES.keys.first,
      desired_length: Project::LENGTHS.keys.first,
      instructions: "None"
    }

    post :create, step: 1, project: data

    project = Project.last

    assert_equal user, project.user
  end

  test "PUT update attaches file upload objects" do
    project = projects(:no_files)
    files = [file_uploads(:three), file_uploads(:four)]

    assert_equal 0, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: files.map(&:uuid)

    assert_equal 2, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update removes files not included in payload" do
    project = projects(:has_files)
    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: []

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

    put :update, id: project.uuid, step: 2, file_upload_uuids: files.map(&:uuid)

    assert_equal 3, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update re-uses existing while also deleting some uploads" do
    project = projects(:has_files)
    files = [file_uploads(:one), file_uploads(:three)]

    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: files.map(&:uuid)

    assert_equal 2, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update associates current_user with project if project has none" do
    project = projects(:has_files)
    sign_in users(:joey)

    assert_equal nil, project.user

    put :update, id: project.uuid, step: 4

    assert_equal users(:joey), project.reload.user
  end

  test "PUT update does not associate current_user with project if project already has one" do
    project = projects(:has_files)
    project.update(user: users(:joey))
    sign_in users(:wilson)

    put :update, id: project.uuid, step: 4

    assert_equal users(:joey), project.reload.user
  end

  test "PUT update attaches a payment method if a token is provided" do
    project = projects(:has_files)
    token = "asdf1234"

    assert_equal nil, project.payment_method

    put :update, id: project.uuid, step: 4, payment_method_token: token

    assert_equal token, project.reload.payment_method.token
  end

  test "checkout caches price on project and updates status" do
    project = projects(:has_files)
    token = "asdf1234"

    assert_equal nil, project.price

    put :update, id: project.uuid, step: 4, payment_method_token: token

    project.reload

    assert_equal :waiting_for_editor, project.status
    assert_not_equal nil, project.price
  end
end
